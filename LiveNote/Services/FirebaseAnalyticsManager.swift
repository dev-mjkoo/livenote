
import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsManager {
    static let shared = FirebaseAnalyticsManager()

    private init() {}

    // MARK: - 기본 설정

    /// 사용자 동의 여부 설정 (GDPR 준수)
    func setAnalyticsEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
        print("📊 Analytics 수집: \(enabled ? "활성화" : "비활성화")")
    }

    // MARK: - 주요 이벤트 추적

    /// 앱 열기
    func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        print("📊 이벤트: 앱 열기")
    }

    /// 메모 작성
    func logMemoWritten(characterCount: Int) {
        Analytics.logEvent("memo_written", parameters: [
            "character_count": characterCount
        ])
        print("📊 이벤트: 메모 작성 (\(characterCount)자)")
    }

    /// 메모 삭제
    func logMemoDeleted() {
        Analytics.logEvent("memo_deleted", parameters: nil)
        print("📊 이벤트: 메모 삭제")
    }

    /// Live Activity 시작
    func logLiveActivityStarted() {
        Analytics.logEvent("live_activity_started", parameters: nil)
        print("📊 이벤트: Live Activity 시작")
    }

    /// Live Activity 종료
    func logLiveActivityEnded(duration: TimeInterval) {
        Analytics.logEvent("live_activity_ended", parameters: [
            "duration_seconds": Int(duration)
        ])
        print("📊 이벤트: Live Activity 종료 (\(Int(duration))초)")
    }

    /// Live Activity 시간 연장
    func logLiveActivityExtended() {
        Analytics.logEvent("live_activity_extended", parameters: nil)
        print("📊 이벤트: Live Activity 시간 연장")
    }

    /// 링크 저장
    func logLinkSaved(category: String) {
        Analytics.logEvent("link_saved", parameters: [
            "category": category
        ])
        print("📊 이벤트: 링크 저장 (카테고리: \(category))")
    }

    /// 링크 열기
    func logLinkOpened(category: String) {
        Analytics.logEvent("link_opened", parameters: [
            "category": category
        ])
        print("📊 이벤트: 링크 열기 (카테고리: \(category))")
    }

    /// 카테고리 생성
    func logCategoryCreated(name: String) {
        Analytics.logEvent("category_created", parameters: [
            "category_name": name
        ])
        print("📊 이벤트: 카테고리 생성 (\(name))")
    }

    /// 카테고리 잠금 설정
    func logCategoryLocked(lockType: String) {
        Analytics.logEvent("category_locked", parameters: [
            "lock_type": lockType // "biometric" or "password"
        ])
        print("📊 이벤트: 카테고리 잠금 설정 (\(lockType))")
    }

    /// 카테고리 삭제
    func logCategoryDeleted() {
        Analytics.logEvent("category_deleted", parameters: nil)
        print("📊 이벤트: 카테고리 삭제")
    }

    /// 공유 Extension 사용
    func logShareExtensionUsed() {
        Analytics.logEvent("share_extension_used", parameters: nil)
        print("📊 이벤트: 공유 Extension 사용")
    }

    // MARK: - 화면 추적

    /// 화면 진입 추적
    func logScreen(name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
        print("📊 화면: \(name)")
    }

    // MARK: - 사용자 속성

    /// 사용자 언어 설정
    func setUserLanguage(_ language: String) {
        Analytics.setUserProperty(language, forName: "user_language")
        print("📊 사용자 속성: 언어 = \(language)")
    }

    /// 총 카테고리 수
    func setTotalCategories(_ count: Int) {
        Analytics.setUserProperty("\(count)", forName: "total_categories")
        print("📊 사용자 속성: 총 카테고리 = \(count)")
    }

    /// 총 링크 수
    func setTotalLinks(_ count: Int) {
        Analytics.setUserProperty("\(count)", forName: "total_links")
        print("📊 사용자 속성: 총 링크 = \(count)")
    }
}
