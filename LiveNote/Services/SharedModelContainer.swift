//
// SharedModelContainer.swift
// LiveNote
//
// ⚠️ 경고: 이 파일은 SwiftData 및 CloudKit 설정을 관리합니다.
//         출시 후 변경 시 모든 사용자 데이터 손실 위험!
//
// 🔴 절대 변경 금지 사항:
// 1. App Group Identifier: "group.com.livenote.shared"
//    - 변경 시 모든 사용자의 SwiftData 데이터 손실
//    - Share Extension, Widget Extension과 공유됨
//    - entitlements 파일과 동일해야 함
//
// 2. CloudKit Container: .automatic
//    - iCloud.mjkoo.livenote 컨테이너 사용
//    - 변경 시 모든 iCloud 동기화 데이터 손실
//
// 3. Schema 등록 모델: [LinkItem, Category]
//    - 새 모델 추가는 가능
//    - 기존 모델 제거 시 데이터 손실
//
// ⚠️ 마이그레이션 코드 부재:
// - 현재 SwiftData 마이그레이션 코드가 없음
// - 스키마 변경 시 마이그레이션 구현 필수
//
// 📝 마이그레이션 추가 시 예제:
// enum SchemaV1: VersionedSchema {
//     static var versionIdentifier = "1.0.0"
//     static var models: [any PersistentModel.Type] {
//         [LinkItem.self, Category.self]
//     }
// }
//
// enum SchemaV2: VersionedSchema {
//     static var versionIdentifier = "2.0.0"
//     static var models: [any PersistentModel.Type] {
//         [LinkItem.self, Category.self, NewModel.self]
//     }
// }
//
// let migrationPlan = SchemaMigrationPlan(
//     schemas: [SchemaV1.self, SchemaV2.self],
//     stages: [
//         // 마이그레이션 로직 추가
//     ]
// )
//
// 📚 관련 파일:
// - LiveNote.entitlements (App Group, CloudKit 설정)
// - LiveNoteShareExtension.entitlements
// - MemoryActivityWidgetExtension.entitlements
// - Models/Category.swift
// - Models/LinkItem.swift
//

import SwiftData
import Foundation

actor SharedModelContainer {
    static let shared = SharedModelContainer()

    private init() {}

    // 🚨 임시: iCloud 그룹 컨테이너 데이터 완전 삭제 (사용 후 주석 처리)
    static func clearAllData() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.livenote.shared") else {
            print("❌ 그룹 컨테이너를 찾을 수 없습니다")
            return
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ 삭제됨: \(fileURL.lastPathComponent)")
            }
            print("✅ iCloud 그룹 컨테이너 데이터 완전 삭제 완료")
        } catch {
            print("❌ 데이터 삭제 실패: \(error)")
        }
    }

    static func create() -> ModelContainer {
        let schema = Schema([
            LinkItem.self,
            Category.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.livenote.shared"),
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
