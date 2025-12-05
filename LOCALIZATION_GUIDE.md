# 🌏 다국어 처리 가이드

LivePost 앱의 모든 문자열은 다국어를 지원합니다.
새로운 기능을 추가할 때 아래 규칙을 **반드시** 따라주세요.

## 📋 필수 규칙

### 1. 문자열은 항상 LocalizationManager 사용
❌ **잘못된 예:**
```swift
Text("저장")
Button("취소") { }
.navigationTitle("링크 저장")
```

✅ **올바른 예:**
```swift
Text(LocalizationManager.shared.string("저장"))
Button(LocalizationManager.shared.string("취소")) { }
.navigationTitle(LocalizationManager.shared.string("링크 저장"))
```

### 2. 한국어를 Key로 사용
- 번역 딕셔너리의 **Key는 항상 한국어**입니다
- 코드에서 찾기 쉽고, 의미 파악이 명확합니다

```swift
// ✅ 좋은 예
LocalizationManager.shared.string("저장하기")
LocalizationManager.shared.string("링크를 복사해오세요")

// ❌ 나쁜 예
LocalizationManager.shared.string("save_button")
LocalizationManager.shared.string("copy_link_message")
```

### 3. 기존 번역 스타일 유지
새로운 번역을 추가할 때는 **기존 번역들의 톤앤매너**를 참고하세요.

#### 톤앤매너 특징:
- 🇰🇷 **한국어**: 친근하고 부드러운 반말체 (예: "저장할 수 있어요", "링크를 공유만 하면 돼요")
- 🇺🇸 **영어**: 간결하고 직관적 (예: "Save", "Just share a link")
- 🇯🇵 **일본어**: 정중한 입니다/ます체 (예: "保存できます", "共有するだけ")
- 🇨🇳 **중국어**: 간결하고 명확 (예: "可以保存", "只需分享链接")

#### 예시:
```swift
"링크 저장 기능도 있어요!": [
    "ko": "링크 저장 기능도 있어요!",           // 부드러운 반말
    "en": "You can save links too!",        // 캐주얼하고 친근함
    "ja": "リンク保存機能もあります！",          // 정중한 입니다체
    "zh": "还能保存链接！"                      // 간결함
]
```

### 4. 변수/동적 텍스트 순서 고려 ⚠️

문자열에 변수나 타이머가 포함된 경우, **언어별로 어순이 다를 수 있습니다**.

#### 예시 1: 타이머 텍스트
```swift
// ❌ 잘못된 방법 - 모든 언어에 같은 순서 적용
Text(endDate, style: .timer) + Text(" 후에 사라짐")
// 결과: "7:55:54 until gone" (영어에서 어색함!)

// ✅ 올바른 방법 - 언어별 순서 분기
if LocalizationManager.shared.isTimerFirst() {
    // 영어: "Gone in 7:55:54"
    Text(LocalizationManager.shared.timerPrefixText()) + Text(endDate, style: .timer)
} else {
    // 한/일/중: "7:55:54 후에 사라짐"
    Text(endDate, style: .timer) + Text(LocalizationManager.shared.timerSuffixText())
}
```

#### 예시 2: 숫자가 포함된 텍스트
```swift
// ❌ 잘못된 방법
Text("\(count)개 카테고리 삭제")
// 영어: "3개 Delete Categories" (의미 불명!)

// ✅ 올바른 방법 - 전용 메서드 사용
Text(LocalizationManager.shared.deleteCategoriesText(count: count))
// 한국어: "3개 카테고리 삭제"
// 영어: "Delete 3 Categories"
// 일본어: "3個のカテゴリを削除"
```

#### 예시 3: 단위 처리
```swift
// 언어별로 단위가 다름
Text("\(count)\(LocalizationManager.shared.countSuffix())")
// 한국어: "5개"
// 일본어: "5個"
// 중국어: "5个"
// 영어: "5" (단위 없음)
```

## 🛠️ 새 번역 추가하는 방법

### 1단계: LocalizationManager.swift 열기
`LivePost/Services/LocalizationManager.swift` 파일 수정

### 2단계: translations 딕셔너리에 추가
```swift
private let translations: [String: [String: String]] = [
    // 기존 번역들...

    "새로운 문자열": [
        "ko": "새로운 문자열",
        "en": "New String",
        "ja": "新しい文字列",
        "zh": "新字符串"
    ],
]
```

### 3단계: 코드에서 사용
```swift
Text(LocalizationManager.shared.string("새로운 문자열"))
```

## 🎯 체크리스트

새로운 기능 추가 시 다음을 확인하세요:

- [ ] 하드코딩된 문자열이 없는가?
- [ ] 모든 문자열이 `LocalizationManager.shared.string()`을 사용하는가?
- [ ] 한국어 Key를 사용했는가?
- [ ] 4개 언어 (한/영/일/중) 모두 번역했는가?
- [ ] 기존 번역 스타일과 톤앤매너가 일치하는가?
- [ ] 변수나 타이머가 포함된 경우, 언어별 어순을 고려했는가?
- [ ] 단위나 조사가 필요한 경우, 언어별로 다르게 처리했는가?

## 🌍 지원 언어

| 언어 | 코드 | 우선순위 |
|------|------|----------|
| 한국어 | ko | Primary (기본) |
| 영어 | en | Secondary |
| 일본어 | ja | Secondary |
| 중국어 | zh | Secondary |

## 💡 참고사항

- 아시아 언어 (한/일/중): 날짜는 해당 언어 Locale 사용
- 그 외 언어: 영어(en_US) Locale 사용
- 번역이 없는 문자열은 한국어가 기본으로 표시됩니다

## 📞 문의

번역 관련 질문이나 개선 사항이 있다면 이슈를 남겨주세요.
