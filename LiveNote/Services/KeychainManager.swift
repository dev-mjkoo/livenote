
import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    private let service = "com.livenote.category.lock"

    /// 카테고리 암호 저장 (iCloud Keychain 동기화)
    func savePassword(_ password: String, for categoryName: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }

        // 기존 암호 삭제
        deletePassword(for: categoryName)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryName,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: true  // iCloud Keychain 동기화
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Keychain: '\(categoryName)' 암호 저장 성공 (iCloud 동기화)")
            return true
        } else {
            print("❌ Keychain: 암호 저장 실패 - \(status)")
            return false
        }
    }

    /// 카테고리 암호 가져오기
    func getPassword(for categoryName: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryName,
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
            print("❌ Keychain: '\(categoryName)' 암호 가져오기 실패 - \(status)")
            return nil
        }
    }

    /// 카테고리 암호 삭제
    func deletePassword(for categoryName: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: categoryName,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny  // 동기화된 항목 포함
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ Keychain: '\(categoryName)' 암호 삭제 성공")
            return true
        } else {
            print("❌ Keychain: 암호 삭제 실패 - \(status)")
            return false
        }
    }

    /// 암호 검증
    func verifyPassword(_ inputPassword: String, for categoryName: String) -> Bool {
        guard let savedPassword = getPassword(for: categoryName) else {
            return false
        }
        return inputPassword == savedPassword
    }
}
