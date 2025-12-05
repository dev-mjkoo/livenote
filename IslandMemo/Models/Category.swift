
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
