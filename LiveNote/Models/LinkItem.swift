
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
