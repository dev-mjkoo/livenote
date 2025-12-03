//
//  LinkItem.swift
//  islandmemo
//
//  Created by Claude on 12/01/25.
//

import Foundation
import SwiftData

@Model
final class LinkItem {
    var url: String = ""
    var title: String?
    var category: String = ""
    var createdAt: Date = Date()

    // 메타데이터
    var metaTitle: String?
    var metaDescription: String?
    var metaImageURL: String?
    var metaImageData: Data?

    init(url: String, title: String? = nil, category: String) {
        self.url = url
        self.title = title
        self.category = category
        self.createdAt = Date()
    }
}
