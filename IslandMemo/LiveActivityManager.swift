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

        let attributes = MemoryNoteAttributes(label: "기억해!")
        let initialState = MemoryNoteAttributes.ContentState(memo: memo)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil // 로컬 업데이트만 사용
            )
            currentActivity = activity
            print("Activity started: \(activity.id)")
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func updateActivity(with memo: String) async {
        guard let activity = currentActivity else { return }
        await updateActivity(memo: memo, activity: activity)
    }

    private func updateActivity(memo: String,
                                activity: Activity<MemoryNoteAttributes>) async {
        let updatedState = MemoryNoteAttributes.ContentState(memo: memo)
        await activity.update(using: updatedState)
        print("Activity updated")
    }

    func endActivity() async {
        guard let activity = currentActivity else { return }
        let finalState = MemoryNoteAttributes.ContentState(memo: "")
        await activity.end(using: finalState, dismissalPolicy: .immediate)
        currentActivity = nil
        print("Activity ended")
    }
}
