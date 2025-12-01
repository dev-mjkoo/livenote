//
//  LinksListView.swift
//  islandmemo
//
//  Created by Claude on 12/01/25.
//

import SwiftUI

struct LinksListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL

    let links: [LinkItem]
    let categories: [String]

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

                if links.isEmpty {
                    // 빈 상태
                    VStack(spacing: 16) {
                        Image(systemName: "link.circle")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary.opacity(0.5))

                        Text("저장된 링크가 없습니다")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 카테고리별 링크 리스트
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(categories, id: \.self) { category in
                                let categoryLinks = links.filter { $0.category == category }

                                if !categoryLinks.isEmpty {
                                    categorySection(category: category, links: categoryLinks)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("저장된 링크")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        }
    }

    @ViewBuilder
    func categorySection(category: String, links: [LinkItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 카테고리 헤더
            HStack {
                Text(category)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                Text("\(links.count)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                    )

                Spacer()
            }

            // 링크 카드들
            VStack(spacing: 8) {
                ForEach(links) { link in
                    linkCard(link)
                }
            }
        }
    }

    @ViewBuilder
    func linkCard(_ link: LinkItem) -> some View {
        Button {
            HapticManager.light()
            if let url = URL(string: link.url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "link")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(link.url)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text(link.createdAt, style: .relative)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.5))
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
        .buttonStyle(.plain)
    }
}

#Preview {
    LinksListView(
        links: [
            LinkItem(url: "https://github.com/example", category: "개발"),
            LinkItem(url: "https://figma.com/example", category: "디자인"),
            LinkItem(url: "https://youtube.com/example", category: "기타")
        ],
        categories: ["개발", "디자인", "기타"]
    )
}
