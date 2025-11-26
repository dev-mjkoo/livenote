//
//  Item.swift
//  islandmemo
//
//  Created by 구민준 on 11/26/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
