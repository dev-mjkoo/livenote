//
//  LinksListView.swift
//  islandmemo
//
//  Created by Claude on 12/01/25.
//

import SwiftUI
import SwiftData

struct LinksListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LinkItem.createdAt, order: .reverse) private var links: [LinkItem]
    @Query(sort: \Category.createdAt, order: .forward) private var storedCategories: [Category]

    let categories: [String]

    @State private var isEditMode: Bool = false
    @State private var selectedCategories: Set<String> = []

    private var categoriesWithLinks: [(category: String, count: Int)] {
        categories.map { category in
            let count = links.filter { $0.category == category }.count
            return (category, count)
        }
    }

    // 카테고리 이름에서 이모지 추출
    private func extractEmoji(from categoryName: String) -> String {
        let emoji = categoryName.first(where: { $0.isEmoji }) ?? "📁"
        return String(emoji)
    }

    // 카테고리 이름에서 텍스트 부분 추출
    private func extractText(from categoryName: String) -> String {
        return categoryName.filter { !$0.isEmoji }.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.black, Color(white: 0.08)]
                        : [Color(white: 0.98), Color(white: 0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if categoriesWithLinks.isEmpty {
                    // 빈 상태
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary.opacity(0.5))

                        Text("카테고리가 없습니다")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 카테고리 그리드 (2열)
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(categoriesWithLinks, id: \.category) { item in
                                categoryCard(category: item.category, count: item.count)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("저장된 링크")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isEditMode {
                        Button("취소") {
                            HapticManager.light()
                            isEditMode = false
                            selectedCategories.removeAll()
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isEditMode && !selectedCategories.isEmpty {
                    Button {
                        HapticManager.medium()
                        deleteSelectedCategories()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("\(selectedCategories.count)개 카테고리 삭제")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    .background(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color.black.opacity(0), Color.black]
                                : [Color.white.opacity(0), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    func categoryCard(category: String, count: Int) -> some View {
        let emoji = extractEmoji(from: category)
        let text = extractText(from: category)
        let isSelected = selectedCategories.contains(category)

        Button {
            if isEditMode {
                // 편집 모드: 선택/해제
                HapticManager.light()
                if selectedCategories.contains(category) {
                    selectedCategories.remove(category)
                } else {
                    selectedCategories.insert(category)
                }
            }
        } label: {
            ZStack(alignment: .topLeading) {
                // 메인 카드 컨텐츠
                if isEditMode {
                    cardContent(emoji: emoji, text: text, count: count)
                } else {
                    // 일반 모드: NavigationLink
                    NavigationLink(destination: CategoryLinksView(category: category)) {
                        cardContent(emoji: emoji, text: text, count: count)
                    }
                    .buttonStyle(.plain)
                }

                // 체크박스 (편집 모드일 때만)
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.5))
                        .padding(12)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    HapticManager.medium()
                    withAnimation {
                        isEditMode = true
                        selectedCategories.insert(category)
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditMode)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    @ViewBuilder
    private func cardContent(emoji: String, text: String, count: Int) -> some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))

            VStack(spacing: 4) {
                if !text.isEmpty {
                    Text(text)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }

                Text("\(count)개")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark
                      ? Color.white.opacity(0.06)
                      : Color.white)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                    radius: 12, x: 0, y: 4
                )
        )
    }

    private func deleteSelectedCategories() {
        var totalLinksDeleted = 0

        for categoryName in selectedCategories {
            // 카테고리에 속한 모든 링크 삭제
            let linksToDelete = links.filter { $0.category == categoryName }
            totalLinksDeleted += linksToDelete.count
            for link in linksToDelete {
                modelContext.delete(link)
            }

            // 카테고리 삭제
            if let category = storedCategories.first(where: { $0.name == categoryName }) {
                modelContext.delete(category)
            }
        }

        do {
            try modelContext.save()
            print("✅ \(selectedCategories.count)개 카테고리 및 관련 링크 \(totalLinksDeleted)개 삭제 성공")
        } catch {
            print("❌ 카테고리 삭제 실패: \(error)")
        }

        // 편집 모드 종료
        isEditMode = false
        selectedCategories.removeAll()
    }
}

// MARK: - Category Links View

struct CategoryLinksView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LinkItem.createdAt, order: .reverse) private var allLinks: [LinkItem]

    let category: String

    @State private var deletingLinkID: PersistentIdentifier? = nil
    @State private var deleteConfirmationTask: Task<Void, Never>?

    private var links: [LinkItem] {
        allLinks.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black, Color(white: 0.08)]
                    : [Color(white: 0.98), Color(white: 0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(links) { link in
                        linkCard(link)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func linkCard(_ link: LinkItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "link")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.7))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.secondary.opacity(0.1))
                )

            Button {
                HapticManager.light()
                if let url = URL(string: link.url) {
                    openURL(url)
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    // 제목이 있으면 제목, 없으면 URL
                    if let title = link.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .lineLimit(1)

                        Text(link.url)
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    } else {
                        Text(link.url)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Text(link.createdAt, style: .relative)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            // 삭제 버튼
            Button {
                let isConfirming = deletingLinkID == link.id
                if isConfirming {
                    // 두 번째 클릭: 실제 삭제
                    HapticManager.medium()
                    deleteLink(link)
                    deletingLinkID = nil
                    deleteConfirmationTask?.cancel()
                } else {
                    // 첫 번째 클릭: 확인 상태로 전환
                    HapticManager.light()
                    deletingLinkID = link.id

                    // 3초 후 자동으로 확인 상태 해제
                    deleteConfirmationTask?.cancel()
                    deleteConfirmationTask = Task {
                        try? await Task.sleep(for: .seconds(3))
                        if !Task.isCancelled {
                            deletingLinkID = nil
                        }
                    }
                }
            } label: {
                Image(systemName: deletingLinkID == link.id ? "trash.fill" : "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(deletingLinkID == link.id ? .red : .secondary.opacity(0.7))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: deletingLinkID == link.id)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(colorScheme == .dark
                      ? Color.white.opacity(0.06)
                      : Color.white)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                    radius: 8, x: 0, y: 2
                )
        )
    }

    private func deleteLink(_ link: LinkItem) {
        modelContext.delete(link)
        do {
            try modelContext.save()
            print("✅ 링크 삭제 성공")
        } catch {
            print("❌ 삭제 실패: \(error)")
        }
    }
}

// MARK: - Character Extension

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

#Preview {
    LinksListView(categories: ["💻 개발", "🎨 디자인", "📌 기타"])
        .modelContainer(for: [LinkItem.self, Category.self], inMemory: true)
}
