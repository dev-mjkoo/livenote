import Foundation
import StoreKit
import UIKit

/// 앱스토어 리뷰 요청을 관리하는 매니저
class ReviewManager {

    /// 싱글톤 인스턴스
    static let shared = ReviewManager()

    private init() {}

    // MARK: - UserDefaults Keys
    private let memoCountKey = "memoWrittenCount"
    private let hasRequestedReviewKey = "hasRequestedReview"

    // MARK: - 메모 작성 카운트

    /// 현재까지 작성한 메모 횟수
    var memoCount: Int {
        UserDefaults.standard.integer(forKey: memoCountKey)
    }

    /// 메모 작성 횟수 증가 및 리뷰 요청 체크
    /// - Returns: 리뷰 요청 Alert을 표시해야 하면 true
    func incrementMemoCount() -> Bool {
        let currentCount = memoCount
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: memoCountKey)

        print("📝 메모 작성 횟수: \(newCount)")

        // 3번째 메모 작성 시 리뷰 요청
        if newCount == 3 {
            return shouldShowReviewAlert()
        }

        return false
    }

    // MARK: - 리뷰 요청

    /// 리뷰 Alert을 표시해야 하는지 확인
    /// - Returns: Alert을 표시해야 하면 true
    private func shouldShowReviewAlert() -> Bool {
        // 이미 리뷰를 요청한 적이 있으면 표시하지 않음
        let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedReviewKey)

        if hasRequested {
            print("⭐️ 이미 리뷰를 요청한 적이 있습니다")
            return false
        }

        print("⭐️ 리뷰 요청 Alert 표시")
        return true
    }

    /// 리뷰 요청을 완료했다고 기록
    func markReviewRequested() {
        UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
        print("⭐️ 리뷰 요청 완료 기록")
    }

    /// 앱스토어 리뷰 페이지로 이동
    func openAppStoreReview() {
        // TODO: 앱스토어에 앱을 출시한 후, 실제 App Store ID로 교체하세요
        // App Store Connect에서 앱의 ID를 확인할 수 있습니다
        // 예: "6670494338" (LiveNote의 예상 ID, 실제 ID로 변경 필요)

        let appID = "6670494338" // ⚠️ 실제 앱 ID로 교체 필요

        // 앱스토어 리뷰 작성 페이지로 직접 이동
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                print("⭐️ 앱스토어 리뷰 페이지로 이동")
            }
        }
    }
}
