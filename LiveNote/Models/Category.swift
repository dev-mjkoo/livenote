import Foundation
import SwiftData

@Model
final class Category {
    // ✅ CloudKit 호환: unique 제거 + 기본값을 선언부에 둠
    var id: UUID = UUID()

    var name: String = ""
    var createdAt: Date = Date()
    var isLocked: Bool = false
    var lockType: String = "biometric" // "biometric" 또는 "password"

    @Relationship(deleteRule: .cascade, inverse: \LinkItem.category)
    var links: [LinkItem]? = []

    init(name: String, isLocked: Bool = false, lockType: String = "biometric") {
        self.name = name
        self.isLocked = isLocked
        self.lockType = lockType
        // self.id / self.createdAt 는 기본값으로도 충분해서 굳이 안 넣어도 됨
    }
}
