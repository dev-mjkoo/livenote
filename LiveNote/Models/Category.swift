
import Foundation
import SwiftData

@Model
final class Category {
    var name: String = ""
    var createdAt: Date = Date()
    var isLocked: Bool = false
    var lockType: String = "biometric" // "biometric" 또는 "password"

    init(name: String, isLocked: Bool = false, lockType: String = "biometric") {
        self.name = name
        self.createdAt = Date()
        self.isLocked = isLocked
        self.lockType = lockType
    }
}
