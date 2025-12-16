
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
