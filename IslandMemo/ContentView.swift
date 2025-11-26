import SwiftUI

struct ContentView: View {

    @State private var memoText: String = ""
    @StateObject private var activityManager = LiveActivityManager.shared

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                // 시스템 라이트/다크 모드 따라가기
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    Text("기억 메모")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .tracking(2)

                    Text("잠금 화면과 Dynamic Island에\n항상 떠 있을 한 줄 메모.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("메모")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)

                        TextField("오늘 꼭 기억할 한 줄을 적어보세요", text: $memoText)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.primary.opacity(0.15), lineWidth: 1)
                            )
                            .textInputAutocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            Task {
                                await activityManager.startActivity(with: memoText)
                            }
                        } label: {
                            Text(activityManager.isActivityRunning ? "Live Activity 다시 시작" : "Live Activity 시작")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(.primary, lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    await activityManager.updateActivity(with: memoText)
                                }
                            } label: {
                                Text("업데이트")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(.primary.opacity(activityManager.isActivityRunning ? 1 : 0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(!activityManager.isActivityRunning)

                            Button {
                                Task {
                                    await activityManager.endActivity()
                                }
                            } label: {
                                Text("종료")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(.primary.opacity(activityManager.isActivityRunning ? 1 : 0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(!activityManager.isActivityRunning)
                        }
                    }

                    Spacer()

                    Text(activityManager.isActivityRunning ? "현재 Live Activity가 진행 중입니다." : "Live Activity가 실행 중이지 않습니다.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, max(20, (width - 500) / 2))
                .padding(.vertical, 32)
            }
        }
    }
}

#Preview {
    ContentView()
}
