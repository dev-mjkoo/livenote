
import SwiftUI
import SwiftData

@main
struct IslandMemoApp: App {
    let sharedModelContainer = SharedModelContainer.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
