//
//  LinkItem.swift
//  islandmemo
//
//  Created by Claude on 12/01/25.
//

import Foundation

struct LinkItem: Identifiable, Codable, Hashable {
    let id: UUID
    let url: String
    let category: String
    let createdAt: Date

    init(url: String, category: String) {
        self.id = UUID()
        self.url = url
        self.category = category
        self.createdAt = Date()
    }
}
