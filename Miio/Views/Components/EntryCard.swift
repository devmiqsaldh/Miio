//
//  EntryCard.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Card que representa uma entrada na lista
struct EntryCard: View {
    let entry: Entry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(entry.title.isEmpty ? "Sem título" : entry.title)
                        .font(DesignSystem.Typography.title3())
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(entry.createdAt.formattedForDiary())
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                if let location = entry.location {
                    LocationView(location: location)
                }
                
                if !entry.photos.isEmpty {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "photo.fill")
                            .font(.caption)
                        Text("\(entry.photos.count) foto\(entry.photos.count > 1 ? "s" : "")")
                            .font(DesignSystem.Typography.caption())
                    }
                    .foregroundColor(DesignSystem.Colors.secondary)
                }
                
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(DesignSystem.Typography.caption())
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs)
                                    .background(DesignSystem.Colors.secondaryBackground)
                                    .cornerRadius(DesignSystem.CornerRadius.small)
                            }
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.subtleSpring) {
                onTap()
            }
        }
    }
}

// MARK: - Previews

#Preview("Entry Card") {
    let entry = Entry(
        title: "Título da Entrada",
        content: "Este é um exemplo de conteúdo de uma entrada do diário. Pode conter várias linhas de texto para descrever o que aconteceu no dia.",
        location: Location(name: "Localização Exemplo", latitude: 0, longitude: 0),
        photos: [Photo(fileName: "photo.jpg")],
        tags: ["tag1", "tag2", "tag3"]
    )
    
    return EntryCard(entry: entry) {
        // Preview apenas
    }
    .padding()
}

