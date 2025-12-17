
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
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.memoWritten, parameters: [
            PersistenceKeys.FirebaseParameters.characterCount: characterCount
        ])
        print("📊 이벤트: 메모 작성 (\(characterCount)자)")
    }

    /// 메모 삭제
    func logMemoDeleted() {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.memoDeleted, parameters: nil)
        print("📊 이벤트: 메모 삭제")
    }

    /// Live Activity 시작
    func logLiveActivityStarted() {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.liveActivityStarted, parameters: nil)
        print("📊 이벤트: Live Activity 시작")
    }

    /// Live Activity 종료
    func logLiveActivityEnded(duration: TimeInterval) {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.liveActivityEnded, parameters: [
            PersistenceKeys.FirebaseParameters.durationSeconds: Int(duration)
        ])
        print("📊 이벤트: Live Activity 종료 (\(Int(duration))초)")
    }

    /// Live Activity 시간 연장
    func logLiveActivityExtended() {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.liveActivityExtended, parameters: nil)
        print("📊 이벤트: Live Activity 시간 연장")
    }

    /// 링크 저장
    func logLinkSaved(category: String) {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.linkSaved, parameters: [
            PersistenceKeys.FirebaseParameters.category: category
        ])
        print("📊 이벤트: 링크 저장 (카테고리: \(category))")
    }

    /// 링크 열기
    func logLinkOpened(category: String) {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.linkOpened, parameters: [
            PersistenceKeys.FirebaseParameters.category: category
        ])
        print("📊 이벤트: 링크 열기 (카테고리: \(category))")
    }

    /// 카테고리 생성
    func logCategoryCreated(name: String) {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.categoryCreated, parameters: [
            PersistenceKeys.FirebaseParameters.categoryName: name
        ])
        print("📊 이벤트: 카테고리 생성 (\(name))")
    }

    /// 카테고리 잠금 설정
    func logCategoryLocked(lockType: String) {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.categoryLocked, parameters: [
            PersistenceKeys.FirebaseParameters.lockType: lockType // "biometric" or "password"
        ])
        print("📊 이벤트: 카테고리 잠금 설정 (\(lockType))")
    }

    /// 카테고리 삭제
    func logCategoryDeleted() {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.categoryDeleted, parameters: nil)
        print("📊 이벤트: 카테고리 삭제")
    }

    /// 공유 Extension 사용
    func logShareExtensionUsed() {
        Analytics.logEvent(PersistenceKeys.FirebaseEvents.shareExtensionUsed, parameters: nil)
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
        Analytics.setUserProperty(language, forName: PersistenceKeys.FirebaseUserProperties.userLanguage)
        print("📊 사용자 속성: 언어 = \(language)")
    }

    /// 총 카테고리 수
    func setTotalCategories(_ count: Int) {
        Analytics.setUserProperty("\(count)", forName: PersistenceKeys.FirebaseUserProperties.totalCategories)
        print("📊 사용자 속성: 총 카테고리 = \(count)")
    }

    /// 총 링크 수
    func setTotalLinks(_ count: Int) {
        Analytics.setUserProperty("\(count)", forName: PersistenceKeys.FirebaseUserProperties.totalLinks)
        print("📊 사용자 속성: 총 링크 = \(count)")
    }
}
