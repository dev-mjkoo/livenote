

import Foundation
import LinkPresentation
import UIKit

actor LinkMetadataService {
    static let shared = LinkMetadataService()

    private init() {}

    func fetchMetadata(for urlString: String) async throws -> LinkMetadata {
        guard let url = URL(string: urlString) else {
            throw LinkMetadataError.invalidURL
        }

        let provider = LPMetadataProvider()
        provider.timeout = 10 // 10초 타임아웃

        let metadata = try await provider.startFetchingMetadata(for: url)

        // 이미지 데이터 가져오기
        var imageData: Data?
        if let imageProvider = metadata.imageProvider {
            imageData = try? await loadImage(from: imageProvider)
        }

        return LinkMetadata(
            title: metadata.title,
            url: metadata.url?.absoluteString,
            imageData: imageData
        )
    }

    private func loadImage(from provider: NSItemProvider) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { image, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let image = image as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.7) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: data)
            }
        }
    }
}

struct LinkMetadata {
    let title: String?
    let url: String?
    let imageData: Data?
}

enum LinkMetadataError: Error {
    case invalidURL
    case fetchFailed
}
