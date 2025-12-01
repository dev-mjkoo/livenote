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
    let title: String? // 선택적 제목
    let category: String
    let createdAt: Date

    init(url: String, title: String? = nil, category: String) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.category = category
        self.createdAt = Date()
    }
}
