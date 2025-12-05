//
//  TagsView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// View que exibe tags
struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Tags")
                .font(DesignSystem.Typography.title3())
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            FlowLayout(spacing: DesignSystem.Spacing.sm) {
                ForEach(tags, id: \.self) { tag in
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

// MARK: - Previews

#Preview("Tags View") {
    TagsView(tags: ["viagem", "férias", "praia", "diversão", "família"])
        .padding()
}

