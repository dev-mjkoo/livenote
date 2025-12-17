//
// LinkItem.swift
// LiveNote
//
// ⚠️ 경고: 이 파일은 SwiftData 모델입니다. 출시 후 변경 시 사용자 데이터 손실 위험!
//
// 🔴 절대 변경 금지 사항:
// 1. url: String - 타입 변경 금지
//    - 사용자가 저장한 모든 링크 데이터
//
// 2. metaImageData: Data? - 타입 변경 금지
//    - 바이너리 이미지 데이터 저장
//    - 타입 변경 시 모든 썸네일 이미지 손실
//
// 3. category: Category? - 관계 변경 주의
//    - Category 모델과 cascade 관계
//    - Category 삭제 시 LinkItem도 함께 삭제됨
//
// 4. CloudKit 동기화 활성화됨
//    - 스키마 변경 시 CloudKit 레코드 타입도 업데이트 필요
//
// 📝 변경이 필요한 경우:
// 1. SwiftData 마이그레이션 코드 작성 필수
// 2. CloudKit 스키마 업데이트 필요
// 3. 기존 데이터 변환 로직 필요
// 4. 충분한 테스트 후 배포
//
// 📚 관련 파일:
// - Services/SharedModelContainer.swift (모델 등록 및 CloudKit 설정)
// - Models/Category.swift (cascade 관계의 부모 모델)
// - Extensions/ContentView+Helpers.swift (링크 저장 로직)
//

import Foundation
import SwiftData

@Model
final class LinkItem {
    var url: String = ""
    var title: String?
    var category: Category?
    var createdAt: Date = Date()

    // 메타데이터
    var metaTitle: String?
    var metaDescription: String?
    var metaImageURL: String?
    var metaImageData: Data?
    var needsMetadataFetch: Bool = false  // 메타데이터를 아직 못 가져온 경우 true

    init(url: String, title: String? = nil, category: Category? = nil, needsMetadataFetch: Bool = false) {
        self.url = url
        self.title = title
        self.category = category
        self.createdAt = Date()
        self.needsMetadataFetch = needsMetadataFetch
    }
}
