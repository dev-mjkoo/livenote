//
//  ShareViewController.swift
//  IslandMemoShareExtension
//
//  Created by 구민준 on 12/3/25.
//

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
              let itemProvider = extensionItem.attachments?.first else {
            closeExtension()
            return
        }

        // URL 타입 확인
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (item, error) in
                if let url = item as? URL {
                    DispatchQueue.main.async {
                        self?.sharedURL = url.absoluteString
                        self?.showShareView()
                    }
                } else {
                    self?.closeExtension()
                }
            }
        } else {
            closeExtension()
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
