# Island Memo 📅

> DON'T FORGET! - 잠금화면에서 항상 볼 수 있는 메모 앱

Island Memo는 iOS Live Activity를 활용하여 중요한 메모를 잠금화면과 Dynamic Island에 항상 표시해주는 앱입니다.

## ✨ 주요 기능

### 📱 Live Activity 잠금화면 표시
- **달력과 메모 동시 표시**: 잠금화면에서 현재 달력과 메모를 한눈에 확인
- **자동 업데이트**: 자정마다 달력이 자동으로 업데이트
- **8시간 타이머**: 메모가 사라지기까지 남은 시간을 실시간으로 표시

### ⏰ 스마트 타이머 시스템
- **8시간 자동 유지**: Live Activity가 8시간 동안 잠금화면에 표시
- **연장 기능**: 앱 내 버튼으로 간편하게 8시간 연장
- **단계별 알림**: 남은 시간에 따라 색상과 메시지 변경
  - 🔴 5분 미만: "긴급 • 지금 앱 열어 연장"
  - 🟠 5-30분: "곧 종료 • 지금 연장하세요"
  - 🟡 30-60분: "n분 남음 • 앱에서 연장"

### 🏝️ Dynamic Island 지원
- **Compact View**: 현재 날짜 표시
- **Expanded View**: 전체 날짜, 메모, 프로그레스 바 표시
- **Minimal View**: 간소화된 날짜 표시

### 🎨 커스터마이징
- **9가지 배경 색상**: 다크그레이, 블랙, 네이비, 퍼플, 핑크, 오렌지, 그린, 블루, 레드
- **선택한 색상 자동 저장**: 앱 재시작 시에도 유지

### 🔗 링크 관리 (추가 기능)
- 중요한 링크 저장 및 카테고리별 관리
- 클립보드 자동 감지
- 링크 공유 기능

## 🛠️ 기술 스택

- **SwiftUI**: 전체 UI 구현
- **ActivityKit**: Live Activity 및 Dynamic Island 구현
- **SwiftData**: 링크 및 카테고리 데이터 저장
- **WidgetKit**: Widget Extension
- **App Intents**: 단축어 및 Control Widget 지원

## 📂 프로젝트 구조

```
IslandMemo/
├── IslandMemo/
│   ├── ContentView.swift              # 메인 화면
│   ├── LiveActivityManager.swift      # Live Activity 관리
│   ├── Models/
│   │   ├── LinkItem.swift             # 링크 데이터 모델
│   │   └── Category.swift             # 카테고리 데이터 모델
│   └── Shared/
│       ├── MemoryNoteAttributes.swift # Live Activity 속성
│       └── Constants.swift            # 앱 상수
│
└── MemoryActivityWidget/
    ├── MemoryActivityWidget.swift     # Live Activity UI
    └── MemoryActivityWidgetControl.swift # Control Widget 및 App Intents
```

## 🔑 핵심 컴포넌트

### LiveActivityManager

Live Activity의 생명주기를 관리하는 싱글톤 매니저입니다.

**주요 기능:**
- `startActivity(with:)`: Live Activity 시작
- `updateActivity(with:)`: 메모 내용 업데이트
- `extendTime()`: 8시간 연장 (기존 Activity 종료 후 새로 생성)
- `endActivity()`: Live Activity 종료
- `restoreActivityIfNeeded()`: 앱 재시작 시 실행 중인 Activity 복원

**연장 메커니즘:**
```swift
// 기존 Activity 완전 종료
await activity.end(nil, dismissalPolicy: .immediate)

// 새 startDate로 Activity 재생성 (시스템 8시간 제한 리셋)
let newActivity = try Activity.request(
    attributes: attributes,
    contentState: initialState,
    pushType: nil
)
```

### MemoryNoteAttributes

Live Activity의 데이터 구조를 정의합니다.

```swift
struct MemoryNoteAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var memo: String
        var startDate: Date        // 타이머 계산 기준
        var backgroundColor: ActivityBackgroundColor
    }
    var label: String
}
```

### CalendarGridView

Live Activity에 표시되는 달력 UI 컴포넌트입니다.

**특징:**
- 현재 월의 전체 달력 표시
- 오늘 날짜 강조 표시
- 이전/다음 달 날짜 흐리게 표시
- 다국어 지원 (한국어, 일본어, 중국어, 영어)

## 🚀 시작하기

### 요구사항
- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

### 설치 및 실행

1. 저장소 클론
```bash
git clone https://github.com/YOUR_USERNAME/islandmemo.git
cd islandmemo
```

2. Xcode에서 프로젝트 열기
```bash
open IslandMemo.xcodeproj
```

3. 시뮬레이터 또는 실제 기기에서 실행

### Live Activity 테스트

Live Activity는 **실제 기기**에서만 제대로 테스트할 수 있습니다.

1. 앱 실행 후 메모 입력
2. 잠금화면에서 Live Activity 확인
3. Dynamic Island 지원 기기(iPhone 14 Pro 이상)에서 확장 UI 확인

## 🔄 주요 업데이트 이력

### v1.0.0
- ✅ Live Activity 기본 구현
- ✅ 달력 표시 기능
- ✅ 8시간 타이머 시스템
- ✅ Dynamic Island 지원
- ✅ 색상 커스터마이징
- ✅ 연장 버튼 (아이콘만 표시)
- ✅ 자정 자동 업데이트

## 💡 알려진 제한사항

### iOS Live Activity 제한
- **8시간 최대 표시 시간**: iOS 시스템 제한으로 8시간 이후 자동 종료
  - 해결방법: 앱 내 연장 버튼 또는 Control Widget으로 연장
- **잠깐 깜빡임**: 연장 시 기존 Activity를 종료하고 새로 생성하므로 순간적으로 사라질 수 있음
  - 이유: 시스템 8시간 제한을 완전히 리셋하기 위함

## 🤝 기여하기

이슈 및 PR은 언제나 환영합니다!

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👨‍💻 개발자

Developed by [@minjunkoo](https://github.com/YOUR_GITHUB_USERNAME)

---

Made with ❤️ using SwiftUI & ActivityKit
