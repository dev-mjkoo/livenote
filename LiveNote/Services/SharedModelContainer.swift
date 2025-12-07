
import SwiftData
import Foundation

actor SharedModelContainer {
    static let shared = SharedModelContainer()

    private init() {}

    static func create() -> ModelContainer {
        let schema = Schema([
            LinkItem.self,
            Category.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.livenote.shared"),
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
