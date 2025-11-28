import ActivityKit
import Foundation
import SwiftUI

// MARK: - Activity Background Color

enum ActivityBackgroundColor: String, Codable, CaseIterable {
    case darkGray = "darkGray"
    case black = "black"
    case navy = "navy"
    case purple = "purple"
    case pink = "pink"
    case orange = "orange"
    case green = "green"
    case blue = "blue"
    case red = "red"

    var color: Color {
        switch self {
        case .darkGray: return Color(white: 0.15)
        case .black: return .black
        case .navy: return Color(red: 0.1, green: 0.15, blue: 0.3)
        case .purple: return Color(red: 0.4, green: 0.2, blue: 0.6)
        case .pink: return Color(red: 0.9, green: 0.4, blue: 0.6)
        case .orange: return Color(red: 0.9, green: 0.5, blue: 0.2)
        case .green: return Color(red: 0.2, green: 0.6, blue: 0.4)
        case .blue: return Color(red: 0.2, green: 0.5, blue: 0.8)
        case .red: return Color(red: 0.8, green: 0.2, blue: 0.3)
        }
    }

    var displayName: String {
        switch self {
        case .darkGray: return "다크그레이"
        case .black: return "블랙"
        case .navy: return "네이비"
        case .purple: return "퍼플"
        case .pink: return "핑크"
        case .orange: return "오렌지"
        case .green: return "그린"
        case .blue: return "블루"
        case .red: return "레드"
        }
    }
}

struct MemoryNoteAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var memo: String
        var startDate: Date
        var backgroundColor: ActivityBackgroundColor
    }

    var label: String
}

// MARK: - Preview helpers

extension MemoryNoteAttributes {
    static var preview: MemoryNoteAttributes {
        MemoryNoteAttributes(label: AppStrings.appName)
    }
}

extension MemoryNoteAttributes.ContentState {
    static var sample: MemoryNoteAttributes.ContentState {
        MemoryNoteAttributes.ContentState(memo: AppStrings.sampleMemo, startDate: Date(), backgroundColor: .darkGray)
    }
}
