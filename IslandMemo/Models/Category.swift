//
//  Category.swift
//  islandmemo
//
//  Created by Claude on 12/02/25.
//

import Foundation
import SwiftData

@Model
final class Category {
    var name: String = ""
    var createdAt: Date = Date()

    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}
