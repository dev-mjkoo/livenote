//
//  islandmemoApp.swift
//  islandmemo
//
//  Created by 구민준 on 11/26/25.
//
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
