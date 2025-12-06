

import UIKit
import SwiftUI
import SwiftData

class ShareViewController: UIViewController {
    private var sharedURL: String?
    private var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 공유된 URL 추출
        extractSharedURL()
    }

    private func extractSharedURL() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments, !attachments.isEmpty else {
            print("❌ Share Extension: No items to share")
            closeExtension()
            return
        }

        print("🔍 Share Extension: \(attachments.count)개의 attachments 발견")

        // 모든 attachments를 순회하면서 URL 찾기
        for (index, itemProvider) in attachments.enumerated() {
            print("📦 Attachment #\(index + 1) 타입들:")
            itemProvider.registeredTypeIdentifiers.forEach { identifier in
                print("  - \(identifier)")
            }
        }

        // URL을 찾을 때까지 모든 attachments 시도
        tryExtractURLFromAttachments(attachments, currentIndex: 0)
    }

    private func tryExtractURLFromAttachments(_ attachments: [NSItemProvider], currentIndex: Int) {
        guard currentIndex < attachments.count else {
            print("❌ Share Extension: 모든 attachments에서 URL을 찾지 못함")
            closeExtension()
            return
        }

        let itemProvider = attachments[currentIndex]
        print("🔄 Attachment #\(currentIndex + 1) 처리 중...")

        // 먼저 URL 타입 시도
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            print("🔗 Share Extension: public.url 타입 시도")
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (item, error) in
                if let error = error {
                    print("❌ Share Extension: URL 로드 에러 - \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.tryExtractFromText(itemProvider, attachments: attachments, currentIndex: currentIndex)
                    }
                    return
                }

                if let url = item as? URL {
                    DispatchQueue.main.async {
                        print("✅ Share Extension: URL 받음 - \(url.absoluteString)")
                        self?.sharedURL = url.absoluteString
                        self?.showShareView()
                    }
                } else if let urlString = item as? String, (urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
                    DispatchQueue.main.async {
                        print("✅ Share Extension: URL 문자열 받음 - \(urlString)")
                        self?.sharedURL = urlString
                        self?.showShareView()
                    }
                } else {
                    print("⚠️ Share Extension: Attachment #\(currentIndex + 1)에서 URL 못 찾음, 다음 시도")
                    DispatchQueue.main.async {
                        guard let self = self,
                              let attachments = self.extensionContext?.inputItems.first as? NSExtensionItem,
                              let items = attachments.attachments else {
                            self?.closeExtension()
                            return
                        }
                        self.tryExtractURLFromAttachments(items, currentIndex: currentIndex + 1)
                    }
                }
            }
        }
        // URL이 없으면 텍스트에서 URL 추출 시도
        else if itemProvider.hasItemConformingToTypeIdentifier("public.text") {
            print("📝 Share Extension: 텍스트 타입 감지")
            tryExtractFromText(itemProvider, attachments: attachments, currentIndex: currentIndex)
        }
        // Plain text도 시도
        else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
            print("📝 Share Extension: Plain 텍스트 타입 감지")
            itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [weak self] (item, error) in
                if let error = error {
                    print("❌ Share Extension: Plain 텍스트 로드 에러 - \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.closeExtension()
                    }
                    return
                }

                if let text = item as? String {
                    DispatchQueue.main.async {
                        guard let self = self,
                              let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
                              let items = extensionItem.attachments else {
                            self?.closeExtension()
                            return
                        }
                        self.extractURLFromText(text, attachments: items, currentIndex: currentIndex)
                    }
                } else {
                    print("⚠️ Share Extension: Attachment #\(currentIndex + 1)에서 텍스트 못 찾음, 다음 시도")
                    DispatchQueue.main.async {
                        guard let self = self,
                              let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
                              let items = extensionItem.attachments else {
                            self?.closeExtension()
                            return
                        }
                        self.tryExtractURLFromAttachments(items, currentIndex: currentIndex + 1)
                    }
                }
            }
        } else {
            print("❌ Share Extension: 지원하지 않는 타입")
            print("💡 첫 번째 타입으로 시도: \(itemProvider.registeredTypeIdentifiers.first ?? "없음")")

            // 마지막 시도: 첫 번째 등록된 타입으로 로드
            if let firstType = itemProvider.registeredTypeIdentifiers.first {
                itemProvider.loadItem(forTypeIdentifier: firstType, options: nil) { [weak self] (item, error) in
                    if let error = error {
                        print("❌ Share Extension: \(firstType) 로드 에러 - \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.closeExtension()
                        }
                        return
                    }

                    print("📦 Share Extension: 받은 아이템 타입 - \(type(of: item))")

                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            print("✅ Share Extension: URL 받음 - \(url.absoluteString)")
                            self?.sharedURL = url.absoluteString
                            self?.showShareView()
                        }
                    } else if let text = item as? String {
                        DispatchQueue.main.async {
                            print("✅ Share Extension: 문자열 받음 - \(text)")
                            guard let self = self,
                                  let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
                                  let items = extensionItem.attachments else {
                                self?.closeExtension()
                                return
                            }
                            self.extractURLFromText(text, attachments: items, currentIndex: currentIndex)
                        }
                    } else {
                        print("⚠️ Share Extension: Attachment #\(currentIndex + 1)에서 처리 불가, 다음 시도")
                        DispatchQueue.main.async {
                            guard let self = self,
                                  let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
                                  let items = extensionItem.attachments else {
                                self?.closeExtension()
                                return
                            }
                            self.tryExtractURLFromAttachments(items, currentIndex: currentIndex + 1)
                        }
                    }
                }
            } else {
                closeExtension()
            }
        }
    }

    private func tryExtractFromText(_ itemProvider: NSItemProvider, attachments: [NSItemProvider], currentIndex: Int) {
        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { [weak self] (item, error) in
            if let error = error {
                print("❌ Share Extension: 텍스트 로드 에러 - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.tryExtractURLFromAttachments(attachments, currentIndex: currentIndex + 1)
                }
                return
            }

            if let text = item as? String {
                DispatchQueue.main.async {
                    print("📝 Share Extension: 텍스트 받음 - \(text)")
                    self?.extractURLFromText(text, attachments: attachments, currentIndex: currentIndex)
                }
            } else if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("📝 Share Extension: Data에서 텍스트 변환 - \(text)")
                    self?.extractURLFromText(text, attachments: attachments, currentIndex: currentIndex)
                }
            } else {
                print("❌ Share Extension: 텍스트 추출 실패 - 받은 타입: \(type(of: item))")
                DispatchQueue.main.async {
                    self?.tryExtractURLFromAttachments(attachments, currentIndex: currentIndex + 1)
                }
            }
        }
    }

    private func extractURLFromText(_ text: String, attachments: [NSItemProvider], currentIndex: Int) {
        // 텍스트에서 URL 추출
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        if let match = matches?.first, let url = match.url {
            print("✅ Share Extension: 텍스트에서 URL 추출 - \(url.absoluteString)")
            sharedURL = url.absoluteString
            showShareView()
        } else if text.hasPrefix("http://") || text.hasPrefix("https://") {
            // 텍스트 자체가 URL인 경우
            print("✅ Share Extension: 텍스트 자체가 URL - \(text)")
            sharedURL = text
            showShareView()
        } else {
            print("⚠️ Share Extension: 이 텍스트는 URL이 아님 (\(text.prefix(50))...), 다음 attachment 시도")
            tryExtractURLFromAttachments(attachments, currentIndex: currentIndex + 1)
        }
    }

    private func showShareView() {
        guard let url = sharedURL else {
            closeExtension()
            return
        }

        let sharedModelContainer = SharedModelContainer.create()

        let shareView = ShareExtensionView(
            url: url,
            onSave: { [weak self] in
                self?.closeExtension()
            },
            onCancel: { [weak self] in
                self?.closeExtension()
            }
        )
        .modelContainer(sharedModelContainer)

        let hosting = UIHostingController(rootView: AnyView(shareView))
        hostingController = hosting

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)
    }

    private func closeExtension() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
