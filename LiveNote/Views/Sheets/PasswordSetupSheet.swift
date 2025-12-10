
import SwiftUI

struct PasswordSetupSheet: View {
    let categoryName: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private var canSave: Bool {
        !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && password.count >= 4
    }

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
                    // 설명
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text(LocalizationManager.shared.string("별도 암호 설정"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))

                        Text(LocalizationManager.shared.string("이 암호는 Face ID와 별개로 작동합니다"))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // 암호 입력
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationManager.shared.string("암호 입력 (최소 4자)"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            SecureField(LocalizationManager.shared.string("암호"), text: $password)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationManager.shared.string("암호 확인"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            SecureField(LocalizationManager.shared.string("암호 다시 입력"), text: $confirmPassword)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                )
                        }

                        // 에러 메시지
                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // 저장 버튼
                    Button {
                        savePassword()
                    } label: {
                        Text(LocalizationManager.shared.string("설정 완료"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canSave ? Color.accentColor : Color.secondary.opacity(0.3))
                            )
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(categoryName)
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

    private func savePassword() {
        if password.count < 4 {
            errorMessage = LocalizationManager.shared.string("암호는 최소 4자 이상이어야 합니다")
            showError = true
            return
        }

        if password != confirmPassword {
            errorMessage = LocalizationManager.shared.string("암호가 일치하지 않습니다")
            showError = true
            return
        }

        onSave(password)
    }
}
