
import SwiftUI

struct PasswordInputSheet: View {
    let categoryName: String
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var password: String = ""
    @State private var showError: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                LinearGradient(
                    colors: AppColors.Background.gradient(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // 자물쇠 아이콘
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text(categoryName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))

                        Text(LocalizationManager.shared.string("암호를 입력하세요"))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)

                    // 암호 입력
                    VStack(spacing: 12) {
                        SecureField(LocalizationManager.shared.string("암호"), text: $password)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onSubmit {
                                verifyPassword()
                            }

                        if showError {
                            Text(LocalizationManager.shared.string("암호가 일치하지 않습니다"))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.red)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // 확인 버튼
                    Button {
                        verifyPassword()
                    } label: {
                        Text(LocalizationManager.shared.string("확인"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(!password.isEmpty ? Color.accentColor : Color.secondary.opacity(0.3))
                            )
                    }
                    .disabled(password.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(LocalizationManager.shared.string("잠금 해제"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.shared.string("취소")) {
                        onCancel()
                    }
                }
            }
        }
    }

    private func verifyPassword() {
        let isValid = KeychainManager.shared.verifyPassword(password, for: categoryName)

        if isValid {
            onSuccess()
        } else {
            withAnimation {
                showError = true
            }
            // 에러 메시지 자동 숨김
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation {
                    showError = false
                }
            }
        }
    }
}
