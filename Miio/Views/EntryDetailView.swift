//
//  EntryDetailView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// View que exibe os detalhes completos de uma entrada
struct EntryDetailView: View {
    let entry: Entry
    @ObservedObject var viewModel: EntryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var entryImages: [UIImage] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(entry.title.isEmpty ? "Sem título" : entry.title)
                            .font(DesignSystem.Typography.largeTitle())
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text(entry.createdAt.formattedWithTime())
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Conteúdo
                    if !entry.content.isEmpty {
                        Text(entry.content)
                            .font(DesignSystem.Typography.body())
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Localização
                    if let location = entry.location {
                        LocationView(location: location)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Fotos
                    if !entry.photos.isEmpty {
                        PhotosGridView(photos: entry.photos, store: viewModel.store)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        TagsView(tags: entry.tags)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Resumo (se disponível)
                    if let summary = entry.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Resumo")
                                .font(DesignSystem.Typography.title3())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text(summary)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .padding(DesignSystem.Spacing.md)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            loadImages()
                            prepareShareItems()
                            showingShareSheet = true
                        } label: {
                            Label("Compartilhar", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            viewModel.loadEntry(entry)
                            showingEditView = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry)
                            dismiss()
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EntryEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(activityItems: shareItems)
                }
            }
            .onAppear {
                loadImages()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadImages() {
        entryImages = entry.photos.compactMap { photo in
            let fileURL = viewModel.store.photosDirectory.appendingPathComponent(photo.fileName)
            guard let imageData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        }
    }
    
    private func prepareShareItems() {
        var items: [Any] = []
        
        var shareText = "📔 \(entry.title)\n\n\(entry.content)"
        
        if let location = entry.location {
            shareText += "\n\n📍 \(location.name)"
        }
        
        if !entry.tags.isEmpty {
            shareText += "\n\n🏷️ \(entry.tags.joined(separator: ", "))"
        }
        
        items.append(shareText)
        items.append(contentsOf: entryImages)
        
        shareItems = items
    }
}

/// View que exibe informações de localização
struct LocationView: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(DesignSystem.Colors.accent)
                Text("Localização")
                    .font(DesignSystem.Typography.title3())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Text(location.name)
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            if let address = location.address {
                Text(address)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

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

/// Layout que organiza views em um fluxo horizontal com quebra de linha
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

/// View que exibe uma grade de fotos
struct PhotosGridView: View {
    let photos: [Photo]
    let store: EntryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Fotos")
                .font(DesignSystem.Typography.title3())
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo, store: store)
                }
            }
        }
    }
}

/// Thumbnail de uma foto
struct PhotoThumbnail: View {
    let photo: Photo
    let store: EntryStore
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            } else {
                Rectangle()
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .frame(height: 150)
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
        guard let imageData = try? Data(contentsOf: fileURL),
              let loadedImage = UIImage(data: imageData) else {
            return
        }
        image = loadedImage
    }
}

// MARK: - Previews

#Preview("Entry Detail - Com Localização") {
    let store = EntryStore()
    let viewModel = EntryViewModel(store: store)
    let sampleEntry = Entry(
        title: "Dia Incrível na Praia",
        content: "Hoje foi um dia maravilhoso! Passei a tarde na praia com amigos, tomamos sol e nadamos muito. O pôr do sol estava simplesmente espetacular.",
        location: Location(
            name: "Praia de Copacabana",
            latitude: -22.9711,
            longitude: -43.1822,
            address: "Copacabana, Rio de Janeiro - RJ"
        ),
        photos: [],
        tags: ["praia", "amigos", "verão"]
    )
    
    return EntryDetailView(entry: sampleEntry, viewModel: viewModel)
}

#Preview("Entry Detail - Com Fotos") {
    let store = EntryStore()
    let viewModel = EntryViewModel(store: store)
    let sampleEntry = Entry(
        title: "Viagem para Paris",
        content: "Finalmente realizei o sonho de visitar Paris! A Torre Eiffel é ainda mais impressionante pessoalmente. Comi croissants deliciosos e caminhei pelas ruas charmosas da cidade.",
        photos: [
            Photo(fileName: "photo1.jpg", caption: "Torre Eiffel"),
            Photo(fileName: "photo2.jpg", caption: "Café da manhã")
        ],
        tags: ["viagem", "paris", "turismo"]
    )
    
    return EntryDetailView(entry: sampleEntry, viewModel: viewModel)
}

#Preview("Location View") {
    let location = Location(
        name: "Parque Ibirapuera",
        latitude: -23.5874,
        longitude: -46.6576,
        address: "Av. Pedro Álvares Cabral, São Paulo - SP"
    )
    
    return LocationView(location: location)
        .padding()
}

#Preview("Tags View") {
    TagsView(tags: ["viagem", "férias", "praia", "diversão", "família"])
        .padding()
}

