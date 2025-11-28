//
//  LiveActivityManager.swift
//  islandmemo
//
//  Created by 구민준 on 11/26/25.
//

import Foundation
import ActivityKit
import Combine

@MainActor
final class LiveActivityManager: ObservableObject {

    static let shared = LiveActivityManager()

    @Published private(set) var currentActivity: Activity<MemoryNoteAttributes>?
    @Published var selectedBackgroundColor: ActivityBackgroundColor = .darkGray
    @Published var activityStartDate: Date? = nil // 실제 startDate 추적
    private var dismissalTask: Task<Void, Never>?

    private init() {}

    var isActivityRunning: Bool {
        currentActivity != nil
    }

    func startActivity(with memo: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }

        // 이미 하나 돌고 있으면 그냥 업데이트로 처리
        if let activity = currentActivity {
            await updateActivity(memo: memo, activity: activity)
            return
        }

        let attributes = MemoryNoteAttributes(label: AppStrings.appName)
        let startDate = Date()
        let initialState = MemoryNoteAttributes.ContentState(
            memo: memo,
            startDate: startDate,
            backgroundColor: selectedBackgroundColor
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil // 로컬 업데이트만 사용
            )
            currentActivity = activity
            activityStartDate = startDate
            print("Activity started: \(activity.id)")

            // 8시간 후 자동 종료 스케줄
            scheduleAutoDismissal()
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func updateActivity(with memo: String) async {
        guard let activity = currentActivity else { return }
        await updateActivity(memo: memo, activity: activity)
    }

    func updateBackgroundColor() async {
        guard let activity = currentActivity else { return }
        await updateActivity(
            memo: activity.contentState.memo,
            backgroundColor: selectedBackgroundColor,
            activity: activity
        )
    }

    func extendTime() async {
        guard let activity = currentActivity else { return }
        // startDate를 현재 시간으로 리셋 (8시간 다시 시작)
        let newStartDate = Date()
        let updatedState = MemoryNoteAttributes.ContentState(
            memo: activity.contentState.memo,
            startDate: newStartDate,
            backgroundColor: activity.contentState.backgroundColor
        )
        await activity.update(using: updatedState)

        // UI 업데이트
        activityStartDate = newStartDate

        // 자동 종료 태스크 재스케줄
        scheduleAutoDismissal()
        print("Activity time extended: 8 hours reset to \(newStartDate)")
    }

    private func updateActivity(memo: String,
                                activity: Activity<MemoryNoteAttributes>) async {
        // 기존 startDate와 backgroundColor 유지
        let startDate = activity.contentState.startDate
        let backgroundColor = activity.contentState.backgroundColor
        let updatedState = MemoryNoteAttributes.ContentState(
            memo: memo,
            startDate: startDate,
            backgroundColor: backgroundColor
        )
        await activity.update(using: updatedState)
        print("Activity updated")
    }

    private func updateActivity(memo: String,
                                backgroundColor: ActivityBackgroundColor,
                                activity: Activity<MemoryNoteAttributes>) async {
        // startDate는 유지, memo와 backgroundColor 업데이트
        let startDate = activity.contentState.startDate
        let updatedState = MemoryNoteAttributes.ContentState(
            memo: memo,
            startDate: startDate,
            backgroundColor: backgroundColor
        )
        await activity.update(using: updatedState)
        print("Activity updated with new color: \(backgroundColor.displayName)")
    }

    func endActivity() async {
        guard let activity = currentActivity else { return }

        // 자동 종료 태스크 취소
        dismissalTask?.cancel()
        dismissalTask = nil

        let finalState = MemoryNoteAttributes.ContentState(
            memo: "",
            startDate: Date(),
            backgroundColor: activity.contentState.backgroundColor
        )
        await activity.end(using: finalState, dismissalPolicy: .immediate)
        currentActivity = nil
        activityStartDate = nil
        print("Activity ended")
    }

    // MARK: - Private Methods

    private func scheduleAutoDismissal() {
        dismissalTask?.cancel()

        dismissalTask = Task {
            // 8시간 대기
            try? await Task.sleep(nanoseconds: 8 * 60 * 60 * 1_000_000_000)

            // 태스크가 취소되지 않았으면 자동 종료
            if !Task.isCancelled {
                await endActivity()
                print("Activity auto-dismissed after 8 hours")
            }
        }
    }
}
