//
//  PhotosGridView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// View que exibe uma grade de fotos
struct PhotosGridView: View {
    let photos: [Photo]
    let store: EntryStore
    
    /// Calcula o número de colunas baseado na quantidade de fotos
    private var columns: [GridItem] {
        switch photos.count {
        case 1:
            // Uma foto: ocupa toda a largura
            return [GridItem(.flexible())]
        case 2:
            // Duas fotos: 2 colunas iguais
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ]
        case 3...4:
            // Três ou quatro fotos: 2 colunas
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ]
        case 5...6:
            // Cinco ou seis fotos: 3 colunas
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs)
            ]
        default:
            // Sete ou mais fotos: 3 colunas com espaçamento menor
            return [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.xs)
            ]
        }
    }
    
    /// Calcula a altura baseada na quantidade de fotos
    private var photoHeight: CGFloat {
        switch photos.count {
        case 1:
            return 250
        case 2:
            return 180
        case 3...4:
            return 150
        case 5...6:
            return 120
        default:
            return 100
        }
    }
    
    /// Calcula o espaçamento entre fotos
    private var gridSpacing: CGFloat {
        switch photos.count {
        case 1:
            return 0
        case 2...4:
            return DesignSystem.Spacing.sm
        default:
            return DesignSystem.Spacing.xs
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Fotos")
                .font(DesignSystem.Typography.title3())
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: gridSpacing) {
                ForEach(photos) { photo in
                    PhotoThumbnail(
                        photo: photo,
                        store: store,
                        isSinglePhoto: photos.count == 1,
                        photoHeight: photoHeight
                    )
                }
            }
        }
    }
}

/// Thumbnail de uma foto
struct PhotoThumbnail: View {
    let photo: Photo
    let store: EntryStore
    let isSinglePhoto: Bool
    let photoHeight: CGFloat
    @State private var imageData: Data?
    
    init(photo: Photo, store: EntryStore, isSinglePhoto: Bool = false, photoHeight: CGFloat = 150) {
        self.photo = photo
        self.store = store
        self.isSinglePhoto = isSinglePhoto
        self.photoHeight = photoHeight
    }
    
    var body: some View {
        Group {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: photoHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            } else {
                Rectangle()
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .frame(height: photoHeight)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let fileURL = store.photosDirectory.appendingPathComponent(photo.fileName)
        imageData = try? Data(contentsOf: fileURL)
    }
}

