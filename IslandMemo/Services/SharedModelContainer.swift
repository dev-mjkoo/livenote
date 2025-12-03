//
//  SharedModelContainer.swift
//  IslandMemo
//
//  Created by Claude on 12/03/25.
//

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
            groupContainer: .identifier("group.com.islandmemo.shared"), // ⚠️ 여기 실제 App Group ID로 변경!
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
