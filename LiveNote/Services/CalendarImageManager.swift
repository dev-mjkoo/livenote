//
// CalendarImageManager.swift
// LiveNote
//
// Live Activity의 달력 영역에 표시할 사진 관리
//

import Foundation
import UIKit
import SwiftUI

final class CalendarImageManager {
    static let shared = CalendarImageManager()

    private init() {}

    /// App Group container URL 가져오기
    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PersistenceKeys.AppGroup.identifier)
    }

    /// 저장된 이미지 파일 URL
    private var imageFileURL: URL? {
        containerURL?.appendingPathComponent(PersistenceKeys.AppGroup.calendarImageFileName)
    }

    // MARK: - 저장

    /// 이미지를 App Group container에 저장
    /// - Parameter image: 저장할 UIImage
    /// - Returns: 성공 여부
    @discardableResult
    func saveImage(_ image: UIImage) -> Bool {
        guard let imageURL = imageFileURL else {
            print("❌ App Group container URL을 찾을 수 없습니다")
            return false
        }

        print("📸 원본 이미지 크기: \(image.size), orientation: \(image.imageOrientation.rawValue)")

        // 이미지 리사이징 및 orientation 정규화 (더 작게)
        let resizedImage = resizeAndNormalizeImage(image, targetWidth: 120)

        print("📸 리사이즈 후 크기: \(resizedImage.size)")

        // JPEG로 변환 (Live Activity 용량 제한 대비 더 강한 압축)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.6) else {
            print("❌ 이미지를 JPEG로 변환 실패")
            return false
        }

        print("📸 JPEG 데이터 크기: \(imageData.count) bytes")

        do {
            // 기존 이미지가 있으면 삭제
            if FileManager.default.fileExists(atPath: imageURL.path) {
                try FileManager.default.removeItem(at: imageURL)
                print("🗑️  기존 이미지 삭제")
            }

            // 새 이미지 저장
            try imageData.write(to: imageURL)
            print("✅ 이미지 저장 성공: \(imageURL.path)")
            return true
        } catch {
            print("❌ 이미지 저장 실패: \(error)")
            return false
        }
    }

    // MARK: - 로드

    /// 저장된 이미지 로드
    /// - Returns: UIImage 또는 nil
    func loadImage() -> UIImage? {
        guard let imageURL = imageFileURL else {
            print("❌ App Group container URL을 찾을 수 없습니다")
            return nil
        }

        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            print("ℹ️ 저장된 이미지가 없습니다")
            return nil
        }

        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            print("❌ 이미지 로드 실패")
            return nil
        }

        print("✅ 이미지 로드 성공")
        return image
    }

    // MARK: - 삭제

    /// 저장된 이미지 삭제
    func deleteImage() {
        guard let imageURL = imageFileURL else { return }

        if FileManager.default.fileExists(atPath: imageURL.path) {
            try? FileManager.default.removeItem(at: imageURL)
            print("🗑️  이미지 삭제 완료")
        }
    }

    // MARK: - Helper

    /// 이미지 리사이징 및 orientation 정규화
    /// - HEIC 포맷을 포함한 모든 이미지 포맷 지원
    private func resizeAndNormalizeImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage {
        let scale = targetWidth / image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSize(width: targetWidth, height: newHeight)

        // UIGraphicsImageRenderer는 자동으로 orientation을 정규화함
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let normalizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return normalizedImage
    }
}
