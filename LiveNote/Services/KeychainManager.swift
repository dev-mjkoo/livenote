//
// KeychainManager.swift
// LiveNote
//
// ⚠️ 경고: 이 파일은 카테고리 비밀번호를 Keychain에 저장합니다.
//         출시 후 변경 시 모든 사용자의 비밀번호 손실 위험!
//
// 🔴 절대 변경 금지 사항:
// 1. Service Identifier: "com.livenote.category.lock"
//    - 변경 시 기존에 저장된 모든 비밀번호 접근 불가
//    - Keychain 쿼리의 핵심 식별자
//
// 2. Account Key: categoryId.uuidString
//    - Category 모델의 UUID를 키로 사용
//    - Category.id 타입 변경 시 모든 비밀번호 손실
//    - Category PK 시스템 변경 시 마이그레이션 필수
//
// 3. iCloud Keychain 동기화: kSecAttrSynchronizable = true
//    - 사용자의 비밀번호가 iCloud로 동기화됨
//    - 앱 삭제 후 재설치해도 비밀번호 유지
//    - 여러 기기 간 자동 동기화
//
// ⚠️ Category 모델과의 강한 결합:
// - Category.id: UUID 타입에 의존
// - Category PK가 String 등으로 변경되면 비밀번호 데이터 손실
// - 마이그레이션 시 Keychain 데이터도 함께 변환 필요
//
// 📝 변경이 필요한 경우:
// 1. 새 service identifier로 마이그레이션 코드 작성
// 2. 기존 Keychain 데이터를 새 키로 복사
// 3. 사용자에게 재인증 요청 (최후의 수단)
//
// 💡 Keychain 특징:
// - 앱 삭제 후에도 데이터 유지 (iCloud 동기화 시)
// - 다른 앱과 데이터 공유 불가 (service identifier로 격리)
// - iOS 시스템이 암호화하여 안전하게 보관
//
// 📚 관련 파일:
// - Models/Category.swift (UUID PK 정의)
// - Views/LinksListView.swift (비밀번호 검증 사용)
// - Views/CategoryPasswordSheet.swift (비밀번호 설정 UI)
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    private let service = "com.livenote.category.lock"

    /// 카테고리 암호 저장 (iCloud Keychain 동기화)
    func savePassword(_ password: String, for categoryId: UUID) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }

        // 기존 암호 삭제
        deletePassword(for: categoryId)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryId.uuidString,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: true  // iCloud Keychain 동기화
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Keychain: '\(categoryId.uuidString)' 암호 저장 성공 (iCloud 동기화)")
            return true
        } else {
            print("❌ Keychain: 암호 저장 실패 - \(status)")
            return false
        }
    }

    /// 카테고리 암호 가져오기
    func getPassword(for categoryId: UUID) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryId.uuidString,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,  // 동기화된 항목 포함
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let password = String(data: data, encoding: .utf8) {
            return password
        } else {
            print("❌ Keychain: '\(categoryId.uuidString)' 암호 가져오기 실패 - \(status)")
            return nil
        }
    }

    /// 카테고리 암호 삭제
    func deletePassword(for categoryId: UUID) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryId.uuidString,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny  // 동기화된 항목 포함
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ Keychain: '\(categoryId.uuidString)' 암호 삭제 성공")
            return true
        } else {
            print("❌ Keychain: 암호 삭제 실패 - \(status)")
            return false
        }
    }

    /// 암호 검증
    func verifyPassword(_ inputPassword: String, for categoryId: UUID) -> Bool {
        guard let savedPassword = getPassword(for: categoryId) else {
            return false
        }
        return inputPassword == savedPassword
    }
}
