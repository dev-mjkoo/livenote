import Foundation

/// 앱 전체 언어 설정을 관리하는 매니저
class LocalizationManager {

    /// 싱글톤 인스턴스
    static let shared = LocalizationManager()

    private init() {}

    /// 사용자의 선호 언어 (en, ko, ja, zh 등)
    var preferredLanguage: String {
        Locale.preferredLanguages.first ?? "en"
    }

    /// 아시아 언어인지 확인 (한국어, 일본어, 중국어)
    var isAsianLanguage: Bool {
        preferredLanguage.hasPrefix("ko") ||
        preferredLanguage.hasPrefix("ja") ||
        preferredLanguage.hasPrefix("zh")
    }

    /// 날짜/시간 포맷에 사용할 Locale
    /// - 아시아 언어: 해당 언어의 Locale
    /// - 그 외: 영어(en_US)
    var dateLocale: Locale {
        isAsianLanguage ? Locale(identifier: preferredLanguage) : Locale(identifier: "en_US")
    }

    /// 현재 언어 코드 (ko, en, ja, zh 등)
    var currentLanguageCode: String {
        if preferredLanguage.hasPrefix("ko") { return "ko" }
        if preferredLanguage.hasPrefix("ja") { return "ja" }
        if preferredLanguage.hasPrefix("zh") { return "zh" }
        return "en"
    }

    // MARK: - 번역 메서드

    /// 한국어 키를 받아서 현재 언어에 맞는 번역된 문자열 반환
    /// - Parameter key: 한국어 문자열 (예: "저장하기")
    /// - Returns: 번역된 문자열
    func string(_ key: String) -> String {
        let lang = currentLanguageCode
        return translations[key]?[lang] ?? key  // 번역 없으면 한국어 그대로 반환
    }

    // MARK: - 번역 데이터

    /// 한국어 키 → [언어코드: 번역] 딕셔너리
    private let translations: [String: [String: String]] = [
        // MARK: - 앱 기본
        "DON'T FORGET!": [
            "ko": "DON'T FORGET!",
            "en": "DON'T FORGET!",
            "ja": "忘れないで！",
            "zh": "别忘了！"
        ],

        // MARK: - 상태
        "LIVE": [
            "ko": "LIVE",
            "en": "LIVE",
            "ja": "ライブ",
            "zh": "直播"
        ],
        "IDLE": [
            "ko": "IDLE",
            "en": "IDLE",
            "ja": "待機中",
            "zh": "闲置"
        ],
        "ON SCREEN": [
            "ko": "ON SCREEN",
            "en": "ON SCREEN",
            "ja": "画面に表示中",
            "zh": "在屏幕上"
        ],
        "READY": [
            "ko": "READY",
            "en": "READY",
            "ja": "準備完了",
            "zh": "准备就绪"
        ],

        // MARK: - 공통 버튼
        "취소": [
            "ko": "취소",
            "en": "Cancel",
            "ja": "キャンセル",
            "zh": "取消"
        ],
        "저장": [
            "ko": "저장",
            "en": "Save",
            "ja": "保存",
            "zh": "保存"
        ],
        "추가": [
            "ko": "추가",
            "en": "Add",
            "ja": "追加",
            "zh": "添加"
        ],
        "확인": [
            "ko": "확인",
            "en": "OK",
            "ja": "確認",
            "zh": "确定"
        ],
        "다음": [
            "ko": "다음",
            "en": "Next",
            "ja": "次へ",
            "zh": "下一步"
        ],
        "시작하기": [
            "ko": "시작하기",
            "en": "Get Started",
            "ja": "始める",
            "zh": "开始使用"
        ],
        "완료": [
            "ko": "완료",
            "en": "Done",
            "ja": "完了",
            "zh": "完成"
        ],

        // MARK: - 링크 관련
        "링크": [
            "ko": "링크",
            "en": "Link",
            "ja": "リンク",
            "zh": "链接"
        ],
        "링크 저장": [
            "ko": "링크 저장",
            "en": "Save Link",
            "ja": "リンク保存",
            "zh": "保存链接"
        ],
        "링크 붙여넣기": [
            "ko": "링크 붙여넣기",
            "en": "Paste Link",
            "ja": "リンクを貼り付け",
            "zh": "粘贴链接"
        ],
        "저장된 링크": [
            "ko": "저장된 링크",
            "en": "Saved Links",
            "ja": "保存済みリンク",
            "zh": "已保存链接"
        ],
        "링크 저장 기능도 있어요!": [
            "ko": "링크 저장 기능도 있어요!",
            "en": "You can save links too!",
            "ja": "リンク保存機能もあります！",
            "zh": "还能保存链接！"
        ],

        // MARK: - 카테고리
        "카테고리": [
            "ko": "카테고리",
            "en": "Category",
            "ja": "カテゴリ",
            "zh": "分类"
        ],
        "카테고리가 없습니다": [
            "ko": "카테고리가 없습니다",
            "en": "No categories",
            "ja": "カテゴリがありません",
            "zh": "暂无分类"
        ],
        "새 카테고리": [
            "ko": "새 카테고리",
            "en": "New Category",
            "ja": "新しいカテゴリ",
            "zh": "新分类"
        ],
        "카테고리 이름을 입력하세요 (이모지 포함 가능)": [
            "ko": "카테고리 이름을 입력하세요 (이모지 포함 가능)",
            "en": "Enter category name (emoji supported)",
            "ja": "カテゴリ名を入力してください（絵文字対応）",
            "zh": "请输入分类名称（支持表情符号）"
        ],
        "카테고리 분류": [
            "ko": "카테고리 분류",
            "en": "Organize by Category",
            "ja": "カテゴリ分類",
            "zh": "分类整理"
        ],
        "링크를 카테고리별로 정리해요": [
            "ko": "링크를 카테고리별로 정리해요",
            "en": "Organize links by category",
            "ja": "リンクをカテゴリ別に整理",
            "zh": "按分类整理链接"
        ],

        // MARK: - 메모
        "메모 (선택)": [
            "ko": "메모 (선택)",
            "en": "Note (Optional)",
            "ja": "メモ（任意）",
            "zh": "备注（可选）"
        ],
        "메모를 입력하세요": [
            "ko": "메모를 입력하세요",
            "en": "Enter a note",
            "ja": "メモを入力してください",
            "zh": "请输入备注"
        ],
        "이 곳을 클릭해 메모 입력": [
            "ko": "이 곳을 클릭해 메모 입력",
            "en": "Tap here to write a note",
            "ja": "ここをタップしてメモを入力",
            "zh": "点击这里输入备注"
        ],

        // MARK: - 온보딩
        "이제 기억할게 있다면": [
            "ko": "이제 기억할게 있다면",
            "en": "Got something to remember?",
            "ja": "覚えておきたいことがあれば",
            "zh": "有什么要记住的？"
        ],
        "잠금화면에서 바로 작성해보세요!": [
            "ko": "잠금화면에서 바로 작성해보세요!",
            "en": "Write it on your lock screen!",
            "ja": "ロック画面で直接入力しましょう！",
            "zh": "在锁屏上直接记录！"
        ],
        "메모와 달력이 잠금화면에 표시되어": [
            "ko": "메모와 달력이 잠금화면에 표시되어",
            "en": "Your notes and calendar appear on your lock screen",
            "ja": "メモとカレンダーがロック画面に表示され",
            "zh": "备忘录和日历显示在锁屏上"
        ],
        "언제든 빠르게 확인할 수 있어요": [
            "ko": "언제든 빠르게 확인할 수 있어요",
            "en": "Check them anytime, instantly",
            "ja": "いつでもすぐに確認できます",
            "zh": "随时快速查看"
        ],
        "잠금화면 미리보기": [
            "ko": "잠금화면 미리보기",
            "en": "Lock Screen Preview",
            "ja": "ロック画面プレビュー",
            "zh": "锁屏预览"
        ],
        "Safari나 다른 앱에서\n링크를 바로 저장할 수 있어요": [
            "ko": "Safari나 다른 앱에서\n링크를 바로 저장할 수 있어요",
            "en": "Save links instantly from Safari\nor any other app",
            "ja": "Safariやほかのアプリからすぐにリンクを保存できます",
            "zh": "从Safari或其他应用\n直接保存链接"
        ],
        "공유하기로 저장": [
            "ko": "공유하기로 저장",
            "en": "Save via Share",
            "ja": "共有で保存",
            "zh": "通过分享保存"
        ],
        "어떤 앱에서든 링크 공유만 하면 돼요": [
            "ko": "어떤 앱에서든 링크 공유만 하면 돼요",
            "en": "Just share a link from any app",
            "ja": "どのアプリからでもリンクを共有するだけ",
            "zh": "从任何应用分享链接即可"
        ],
        "미리보기 지원": [
            "ko": "미리보기 지원",
            "en": "Preview Support",
            "ja": "プレビュー対応",
            "zh": "支持预览"
        ],
        "링크 썸네일과 제목을 자동으로 가져와요": [
            "ko": "링크 썸네일과 제목을 자동으로 가져와요",
            "en": "Automatically fetches thumbnails and titles",
            "ja": "サムネイルとタイトルを自動取得",
            "zh": "自动获取缩略图和标题"
        ],

        // MARK: - 기타
        "링크를 복사해오세요": [
            "ko": "링크를 복사해오세요",
            "en": "Please copy a link first",
            "ja": "リンクをコピーしてください",
            "zh": "请先复制链接"
        ],
        "이미 존재하는 카테고리입니다": [
            "ko": "이미 존재하는 카테고리입니다",
            "en": "Category already exists",
            "ja": "すでに存在するカテゴリです",
            "zh": "分类已存在"
        ],
        "개": [
            "ko": "개",
            "en": "",  // 영어는 "items" 같은 단어를 별도로 처리
            "ja": "個",
            "zh": "个"
        ],
        "삭제": [
            "ko": "삭제",
            "en": "Delete",
            "ja": "削除",
            "zh": "删除"
        ],
        "공유": [
            "ko": "공유",
            "en": "Share",
            "ja": "共有",
            "zh": "分享"
        ],
        "카테고리 삭제": [
            "ko": "카테고리 삭제",
            "en": "Delete Categories",
            "ja": "カテゴリ削除",
            "zh": "删除分类"
        ]
    ]

    // MARK: - 포맷 문자열 메서드

    /// 카테고리 삭제 버튼 텍스트 (숫자 포함)
    func deleteCategoriesText(count: Int) -> String {
        let lang = currentLanguageCode
        switch lang {
        case "ko": return "\(count)개 카테고리 삭제"
        case "ja": return "\(count)個のカテゴリを削除"
        case "zh": return "删除\(count)个分类"
        default: return "Delete \(count) \(count == 1 ? "Category" : "Categories")"
        }
    }

    /// "개" 단위 (언어별)
    func countSuffix() -> String {
        let lang = currentLanguageCode
        switch lang {
        case "ko": return "개"
        case "ja": return "個"
        case "zh": return "个"
        default: return ""  // 영어는 없음
        }
    }

    /// 타이머 텍스트가 앞에 오는지 뒤에 오는지 확인
    func isTimerFirst() -> Bool {
        let lang = currentLanguageCode
        return lang == "en"  // 영어만 타이머가 앞에 옴
    }

    /// 타이머 텍스트 (타이머 제외)
    func timerSuffixText() -> String {
        let lang = currentLanguageCode
        switch lang {
        case "ko": return " 후에 사라짐"
        case "ja": return " 後に消えます"
        case "zh": return " 后消失"
        default: return " until gone"
        }
    }

    /// 타이머 텍스트 (앞에 붙는 경우 - 영어)
    func timerPrefixText() -> String {
        let lang = currentLanguageCode
        switch lang {
        case "en": return "Gone in "
        default: return ""
        }
    }
}
