import SwiftUI
import PhotosUI
import ActivityKit

// HEIC 포맷 지원을 위한 Image Transferable
struct ImageTransferable: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return ImageTransferable(image: uiImage)
        }
    }

    enum TransferError: Error {
        case importFailed
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @StateObject private var activityManager = LiveActivityManager.shared
    @AppStorage(PersistenceKeys.UserDefaults.analyticsEnabled) private var analyticsEnabled: Bool = true
    @AppStorage(PersistenceKeys.UserDefaults.usePhotoInsteadOfCalendar) private var usePhoto: Bool = false
    @State private var showAnalyticsDisableAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            List {
                // 앱 정보 섹션
                Section {
                    HStack {
                        Text(LocalizationManager.shared.string("앱 이름"))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("LiveNote")
                            .foregroundStyle(.primary)
                    }

                    HStack {
                        Text(LocalizationManager.shared.string("버전"))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.primary)
                    }

                    Button {
                        openPrivacyPolicy()
                    } label: {
                        HStack {
                            Text(LocalizationManager.shared.string("개인정보처리방침"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(LocalizationManager.shared.string("정보"))
                }

                // Live Activity 설정 섹션
                Section {
                    Toggle(isOn: $usePhoto) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizationManager.shared.string("사진으로 표시"))
                                .foregroundStyle(.primary)
                            Text(LocalizationManager.shared.string("잠금화면에서 달력 대신 사진을 표시합니다"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.blue)
                    .onChange(of: usePhoto) { _, _ in
                        // 설정 변경 시 즉시 Activity 업데이트
                        Task {
                            await updateCurrentActivity()
                        }
                    }

                    if usePhoto {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            HStack {
                                if let image = selectedImage ?? CalendarImageManager.shared.loadImage() {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizationManager.shared.string("사진 선택"))
                                        .foregroundStyle(.primary)
                                    Text(LocalizationManager.shared.string("앨범에서 선택하기"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading, 8)

                                Spacer()
                            }
                        }
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                guard let item = newItem else {
                                    print("❌ PhotosPickerItem이 nil입니다")
                                    return
                                }

                                print("🔍 PhotosPickerItem 선택됨: \(item)")

                                // 방법 1: Data로 로드 시도
                                if let imageData = try? await item.loadTransferable(type: Data.self) {
                                    print("📸 Data로 로드 성공: \(imageData.count) bytes")

                                    if let image = UIImage(data: imageData) {
                                        print("✅ UIImage 변환 성공: \(image.size)")
                                        selectedImage = image
                                        CalendarImageManager.shared.saveImage(image)
                                        await updateCurrentActivity()
                                        return
                                    } else {
                                        print("⚠️ Data -> UIImage 변환 실패, 다른 방법 시도")
                                    }
                                }

                                // 방법 2: Image Transferable로 로드 시도
                                if let transferredImage = try? await item.loadTransferable(type: ImageTransferable.self) {
                                    let uiImage = transferredImage.image
                                    print("✅ ImageTransferable로 로드 성공: \(uiImage.size)")
                                    selectedImage = uiImage
                                    CalendarImageManager.shared.saveImage(uiImage)
                                    await updateCurrentActivity()
                                    return
                                }

                                print("❌ 모든 이미지 로드 방법 실패")
                            }
                        }
                    }
                } header: {
                    Text("Live Activity")
                }

                // 분석 데이터 수집 섹션
                Section {
                    Toggle(isOn: Binding(
                        get: { analyticsEnabled },
                        set: { newValue in
                            // 끄려고 할 때만 확인 알림 표시
                            if !newValue && analyticsEnabled {
                                showAnalyticsDisableAlert = true
                            } else {
                                analyticsEnabled = newValue
                                FirebaseAnalyticsManager.shared.setAnalyticsEnabled(newValue)
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizationManager.shared.string("분석 데이터 수집"))
                                .foregroundStyle(.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizationManager.shared.string("앱 개선을 위해 익명화된 사용 데이터를 수집합니다"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(LocalizationManager.shared.string("메모, 링크 등 사용자가 저장한 데이터는 절대 수집하지 않습니다"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.blue)
                } header: {
                    Text(LocalizationManager.shared.string("개인정보 보호"))
                }
            }
            .navigationTitle(LocalizationManager.shared.string("설정"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(LocalizationManager.shared.string("완료"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .alert(
                LocalizationManager.shared.string("분석 데이터 수집을 끄시겠습니까?"),
                isPresented: $showAnalyticsDisableAlert
            ) {
                Button(LocalizationManager.shared.string("끄기"), role: .destructive) {
                    analyticsEnabled = false
                    FirebaseAnalyticsManager.shared.setAnalyticsEnabled(false)
                }
                Button(LocalizationManager.shared.string("유지하기"), role: .cancel) {}
            } message: {
                Text(LocalizationManager.shared.string("메모, 링크 등 개인 데이터는 수집하지 않으며, 앱 오류 분석과 개선을 위해서만 사용됩니다."))
            }
        }
    }

    private func openPrivacyPolicy() {
        let lang = LocalizationManager.shared.currentLanguageCode
        let urlString: String

        switch lang {
        case "ko":
            urlString = "https://buly.kr/2Uk5GiV"
        case "ja":
            urlString = "https://buly.kr/6iiGoIf"
        case "zh":
            urlString = "https://buly.kr/EI4qzNy"
        default: // "en"
            urlString = "https://buly.kr/8embbHE"
        }

        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    /// 현재 실행 중인 Activity 업데이트 (설정 변경 즉시 반영)
    private func updateCurrentActivity() async {
        guard let activity = activityManager.currentActivity else {
            return
        }

        // 현재 메모 내용으로 업데이트 (usePhoto 설정이 변경됨)
        await activityManager.updateActivity(with: activity.content.state.memo)
    }
}
