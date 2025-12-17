//
// Category.swift
// LiveNote
//
// ⚠️ 경고: 이 파일은 SwiftData 모델입니다. 출시 후 변경 시 사용자 데이터 손실 위험!
//
// 🔴 절대 변경 금지 사항:
// 1. id: UUID - Primary Key 타입 변경 금지
//    - Keychain 비밀번호 키로 사용됨 (KeychainManager.swift)
//    - 타입 변경 시 모든 비밀번호 데이터 손실
//
// 2. lockType: String - 값 변경 금지
//    - 허용 값: "biometric", "password"
//    - 기존 사용자 데이터와 호환성 유지 필수
//
// 3. CloudKit 동기화 활성화됨
//    - 스키마 변경 시 CloudKit 레코드 타입도 업데이트 필요
//    - SharedModelContainer.swift 참고
//
// 📝 변경이 필요한 경우:
// 1. SwiftData 마이그레이션 코드 작성 필수
// 2. CloudKit 스키마 업데이트 필요
// 3. Keychain 데이터 마이그레이션 계획 필요
// 4. 충분한 테스트 후 배포
//
// 📚 관련 파일:
// - Services/SharedModelContainer.swift (모델 등록 및 CloudKit 설정)
// - Services/KeychainManager.swift (Category UUID를 키로 사용)
// - Models/LinkItem.swift (cascade 관계)
//

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
