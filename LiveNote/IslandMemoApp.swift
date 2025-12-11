
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct IslandMemoApp: App {
    let sharedModelContainer = SharedModelContainer.create()

    init() {
        // Firebase 초기화
        FirebaseApp.configure()
        print("✅ Firebase 초기화 완료")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
