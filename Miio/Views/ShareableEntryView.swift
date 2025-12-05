//
//  ShareableEntryView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#endif

/// View renderizável para compartilhamento como imagem (com imagens pré-carregadas)
struct ShareableEntryViewWithImages: View {
    let entry: Entry
    let images: [UIImage]
    
    /// Calcula o número de colunas baseado na quantidade de imagens
    private var photoColumns: [GridItem] {
        switch images.count {
        case 1:
            return [GridItem(.flexible())]
        case 2:
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ]
        default:
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text(entry.title.isEmpty ? "Entrada do Diário" : entry.title)
                    .font(DesignSystem.Typography.largeTitle())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(entry.createdAt.formattedWithTime())
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
            
            // Conteúdo
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(DesignSystem.Typography.body())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            // Localização
            if let location = entry.location {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "location.fill")
                        .foregroundColor(DesignSystem.Colors.accent)
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(location.name)
                            .font(DesignSystem.Typography.bodyBold())
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        if let address = location.address {
                            Text(address)
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            // Fotos - Grid como no app
            if !images.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Fotos")
                        .font(DesignSystem.Typography.title3())
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    LazyVGrid(columns: photoColumns, spacing: DesignSystem.Spacing.sm) {
                        ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: images.count == 1 ? 400 : 300)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
            
            // Tags
            if !entry.tags.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Tags")
                        .font(DesignSystem.Typography.title3())
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(DesignSystem.Typography.caption())
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .cornerRadius(DesignSystem.CornerRadius.small)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
            
            Spacer()
        }
        .frame(width: 1200, height: 1600)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Extensions

/// Extensão para renderizar SwiftUI View como UIImage
/// Utilizada para compartilhamento de entradas como imagem
@available(iOS 16.0, *)
extension View {
    /// Renderiza a view como uma imagem de alta resolução
    /// - Returns: UIImage renderizada ou nil em caso de erro
    @MainActor
    func renderAsImage() -> UIImage? {
        #if canImport(UIKit)
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3.0 // Alta resolução para compartilhamento
        return renderer.uiImage
        #else
        return nil
        #endif
    }
}


