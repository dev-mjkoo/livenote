//
//  ShortcutGuideView.swift
//  IslandMemo
//

import SwiftUI

// MARK: - Shortcut Guide View

struct ShortcutGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage = 0
    var onDismiss: (() -> Void)? = nil

    private let pages = [
        GuidePage(
            icon: "liveactivity",
            title: "잠금화면 메모",
            description: "잠금화면에 표시되는 메모/달력은\n시스템 상 8시간 뒤에 자동으로 꺼집니다",
            step: "이를 방지하기 위해 단축어 자동화 설정을 추가하면\n24시간 내내 항상 보이게 할 수 있어요"
        ),
        GuidePage(
            icon: "text",
            title: "1단계: 자동화 만들기",
            description: "1. '단축어' 앱 실행\n2. 하단 '자동화' 탭 선택\n3. 우측 상단 '+' 버튼 클릭\n4. '개인용 자동화 생성' 선택\n5. '특정 시간' 클릭",
            step: nil
        ),
        GuidePage(
            icon: "image_step2",
            title: "2단계: 시간 설정",
            description: "1. 시간: 00:00 설정\n2. 반복: 매일\n3. '즉시 실행' 선택\n4. '다음' 버튼 클릭",
            step: nil
        ),
        GuidePage(
            icon: "text",
            title: "3단계: 동작 추가",
            description: "1. 검색창에 '\(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Island Memo")' 입력\n2. '잠금화면 표시 시간 연장' 선택",
            step: nil
        ),
        GuidePage(
            icon: "step4",
            title: "4단계: 나머지 2개 추가",
            description: "같은 방법으로 08:00, 16:00 자동화 생성",
            step: "총 3개 자동화가 만들어지면\n24시간 자동 연장 설정 완료!"
        ),
        GuidePage(
            icon: "checkmark.circle.fill",
            title: "설정 완료!",
            description: "이제 메모가 24시간 내내 유지됩니다",
            step: "00시, 08시, 16시마다\n자동으로 잠금화면 표시가 연장돼요"
        )
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.black, Color(white: 0.08)]
                        : [Color(white: 0.98), Color(white: 0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // TabView
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            GuidePageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // 하단 UI: 건너뛰기 → Page Dots → 다음 버튼
                    VStack(spacing: 16) {
                        // 건너뛰기 (마지막 페이지 아닐 때만)
                        if currentPage != pages.count - 1 {
                            Button {
                                HapticManager.light()
                                onDismiss?()
                                dismiss()
                            } label: {
                                Text("건너뛰기")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }

                        // Page Dots
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.accentColor : Color.secondary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }
                        .padding(.vertical, 4)

                        // 다음/완료 버튼
                        if currentPage == pages.count - 1 {
                            Button {
                                HapticManager.medium()
                                onDismiss?()
                                dismiss()
                            } label: {
                                Text("완료")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor)
                                    )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                HapticManager.light()
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack {
                                    Text("다음")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("단축어 설정 가이드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        onDismiss?()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct GuidePage {
    let icon: String
    let title: String
    let description: String
    let step: String?
}

struct GuidePageView: View {
    let page: GuidePage
    @Environment(\.colorScheme) private var colorScheme
    @State private var animateIcon = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                // 제목
                Text(page.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)

                // Step indicator (1,2,3,4단계만)
                if page.icon == "text" || page.icon == "image_step2" || page.icon == "step4" {
                    stepIndicatorView
                        .padding(.bottom, 16)
                }

                // 설명 (AttributedString으로 강조 처리)
                descriptionView
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)

                // 추가 단계 (step이 있으면 먼저 표시)
                if let step = page.step {
                    stepView(step)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }

                // 첫 페이지(liveactivity)는 아래쪽에 프리뷰 표시
                if page.icon == "liveactivity" {
                    Spacer(minLength: 20)
                }

                // 아이콘 + 시각적 데모
                visualDemo
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            animateIcon = true
                        }
                    }
                    .padding(.bottom, 24)

                Spacer(minLength: 40)
            }
        }
        .scrollIndicators(.hidden)
    }

    // 현재 단계 계산
    private var currentStep: Int {
        if page.title.contains("1단계") {
            return 1
        } else if page.title.contains("2단계") {
            return 2
        } else if page.title.contains("3단계") {
            return 3
        } else if page.title.contains("4단계") {
            return 4
        } else {
            return 0
        }
    }

    // Step Indicator (1→2→3→4 단계 표시)
    @ViewBuilder
    private var stepIndicatorView: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let circleWidth: CGFloat = 32
            let totalCircles: CGFloat = 4
            let totalGaps: CGFloat = 3 // 원 사이 간격 3개

            // 사용 가능한 너비 = 전체 너비 - 모든 원의 너비
            let availableWidth = totalWidth - (circleWidth * totalCircles)
            // 각 연결선의 너비 = 사용 가능한 너비 / 간격 개수
            let lineWidth = availableWidth / totalGaps

            HStack(spacing: 0) {
                ForEach(1...4, id: \.self) { step in
                    // 원형 숫자
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? Color.accentColor : Color.secondary.opacity(0.2))
                            .frame(width: circleWidth, height: circleWidth)

                        Text("\(step)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(step <= currentStep ? .white : .secondary.opacity(0.5))
                    }

                    // 연결선 (마지막 아이템 제외)
                    if step < 4 {
                        Rectangle()
                            .fill(step < currentStep ? Color.accentColor : Color.secondary.opacity(0.2))
                            .frame(width: lineWidth, height: 2)
                    }
                }
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 40)
    }

    // 설명 텍스트 (강조 포함)
    @ViewBuilder
    private var descriptionView: some View {
        Text(highlightedDescription())
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .lineSpacing(6)
    }

    // 강조해야 할 부분들을 AttributedString으로 처리
    private func highlightedDescription() -> AttributedString {
        var attributed = AttributedString(page.description)

        // 강조할 키워드들
        let highlights = [
            "'단축어'", "'자동화'", "'+'",
            "'개인용 자동화 생성'", "'특정 시간'",
            "00:00", "매일", "'즉시 실행'", "'다음'",
            "'잠금화면 표시 시간 연장'",
            "08:00", "16:00", "3개"
        ]

        for highlight in highlights {
            if let range = attributed.range(of: highlight) {
                attributed[range].foregroundColor = .accentColor
                attributed[range].font = .system(size: 16, weight: .bold, design: .rounded)
            }
        }

        return attributed
    }

    // 추가 단계 뷰
    @ViewBuilder
    private func stepView(_ step: String) -> some View {
        Text(highlightedStep(step))
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark
                          ? Color.white.opacity(0.06)
                          : Color.black.opacity(0.04))
            )
    }

    private func highlightedStep(_ step: String) -> AttributedString {
        var attributed = AttributedString(step)

        let stepHighlights = [
            "08:00", "16:00", "3개", "24시간"
        ]

        for highlight in stepHighlights {
            if let range = attributed.range(of: highlight) {
                attributed[range].foregroundColor = .accentColor
                attributed[range].font = .system(size: 14, weight: .bold, design: .rounded)
            }
        }

        return attributed
    }

    @ViewBuilder
    private var visualDemo: some View {
        switch page.icon {
        case "liveactivity":
            // Live Activity UI 미리보기
            liveActivityDemo
        case "text":
            // 텍스트 전용 페이지 - 아이콘 없음
            EmptyView()
        case "image_step2":
            // 2단계 UI 시뮬레이션
            timeSettingUIDemo
        case "step4":
            // 4단계: 3개 자동화 리스트 시뮬레이션
            automationListDemo
        default:
            // 기본 아이콘
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 20)
                .scaleEffect(animateIcon ? 1.1 : 1.0)
        }
    }

    // MARK: - Demo Views

    private var timeSettingUIDemo: some View {
        VStack(spacing: 20) {
            // 특정 시간 섹션
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(NSLocalizedString("특정 시간", comment: ""))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))

                // 시간 피커 모형
                VStack(spacing: 8) {
                    // 00:00 선택된 시간
                    HStack(spacing: 8) {
                        Text("00")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(.primary)
                        Text(":")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(.primary)
                        Text("00")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
                    )
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
            .cornerRadius(10)

            // 반복 섹션
            VStack(alignment: .leading, spacing: 0) {
                Text(NSLocalizedString("반복", comment: ""))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                VStack(spacing: 0) {
                    // 매일
                    HStack {
                        Text(NSLocalizedString("매일", comment: ""))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))

                    Divider()
                        .padding(.leading, 16)

                    // 매주
                    HStack {
                        Text(NSLocalizedString("매주", comment: ""))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))

                    Divider()
                        .padding(.leading, 16)

                    // 매월
                    HStack {
                        Text(NSLocalizedString("매월", comment: ""))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                }
                .cornerRadius(10)
            }

            // 확인 후 실행 / 즉시 실행 섹션
            VStack(spacing: 0) {
                // 확인 후 실행
                HStack {
                    Text(NSLocalizedString("확인 후 실행", comment: ""))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))

                Divider()
                    .padding(.leading, 16)

                // 즉시 실행 (선택됨)
                HStack {
                    Text(NSLocalizedString("즉시 실행", comment: ""))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .scaleEffect(animateIcon ? 1.15 : 1.0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))

                Divider()
                    .padding(.leading, 16)

                // 실행되면 알리기 (토글)
                HStack {
                    Text(NSLocalizedString("실행되면 알리기", comment: ""))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Toggle("", isOn: .constant(false))
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
            .cornerRadius(10)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 350)
    }

    private var liveActivityDemo: some View {
        // 실제 Live Activity UI 재사용
        LiveActivityLockScreenPreview(
            label: AppStrings.appMessage,
            memo: "오늘 할 일\n- 디자인 피드백\n- 온보딩 수정",
            startDate: Date().addingTimeInterval(-30 * 60), // 30분 전 시작 (7시간 30분 남음)
            backgroundColor: .darkGray
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.15))
                .shadow(color: .black.opacity(0.3), radius: 12, y: 8)
        )
        .padding(.horizontal, 32)
        .scaleEffect(animateIcon ? 1.02 : 1.0)
    }

    private var shortcutAppDemo: some View {
        VStack(spacing: 24) {
            // 단축어 앱 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.gradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.4), radius: 12, y: 8)

                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 8)

            // 하단 탭 바 시뮬레이션
            HStack(spacing: 50) {
                VStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("나의 단축어")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.7))
                }

                VStack(spacing: 6) {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .font(.system(size: 26))
                        .foregroundColor(.accentColor)
                    Text("자동화")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .scaleEffect(animateIcon ? 1.08 : 1.0)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 50)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            )

            // + 버튼 (펄스 효과)
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(animateIcon ? 1.4 : 1.0)
                    .opacity(animateIcon ? 0 : 0.5)

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.5), radius: 8)
            }
        }
        .padding(.vertical, 20)
    }

    private var timeSettingDemo: some View {
        VStack(spacing: 28) {
            // 시간 표시
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    .frame(height: 100)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                Text("00:00")
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 40)

            // 화살표
            Image(systemName: "arrow.down")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary.opacity(0.5))

            // 동작 추가 버튼
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                Text("Island Memo")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.gradient)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 12, y: 6)
            )
            .scaleEffect(animateIcon ? 1.04 : 1.0)

            // 잠금화면 표시 시간 연장 액션
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                Text("잠금화면 표시 시간 연장")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            )
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }

    private var automationListDemo: some View {
        VStack(spacing: 0) {
            // 3개 자동화 리스트
            ForEach(Array(["00:00", "08:00", "16:00"].enumerated()), id: \.offset) { index, time in
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        // 시계 아이콘
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 40, height: 40)

                            Image(systemName: "clock.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        // 화살표
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.5))

                        // 앱 아이콘 (Bundle에서 가져오기)
                        if let appIcon = getAppIcon() {
                            Image(uiImage: appIcon)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(9)
                        } else {
                            // Fallback: 기본 아이콘
                            ZStack {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "app.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        }

                        // 텍스트
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("매일 %@에", comment: ""), time))
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.primary)
                            Text(NSLocalizedString("잠금화면 표시 시간 연장", comment: ""))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))

                    // 마지막 아이템이 아니면 구분선
                    if index < 2 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
        }
        .cornerRadius(10)
        .padding(.horizontal, 24)
        .scaleEffect(animateIcon ? 1.005 : 1.0)
        .padding(.vertical, 20)
    }

    // 앱 아이콘 가져오기
    private func getAppIcon() -> UIImage? {
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
