//
//  EntryDetailView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

// UIImage necessário apenas para carregar imagens do disco
#if canImport(UIKit)
import UIKit
#endif

/// View que exibe os detalhes completos de uma entrada
struct EntryDetailView: View {
    let entry: Entry
    @ObservedObject var viewModel: EntryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    
    /// Entrada atualizada do store
    private var currentEntry: Entry {
        viewModel.store.entries.first { $0.id == entry.id } ?? entry
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(currentEntry.title.isEmpty ? "Sem título" : currentEntry.title)
                            .font(DesignSystem.Typography.largeTitle())
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text(currentEntry.createdAt.formattedWithTime())
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Conteúdo
                    if !currentEntry.content.isEmpty {
                        Text(currentEntry.content)
                            .font(DesignSystem.Typography.body())
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Localização
                    if let location = currentEntry.location {
                        LocationView(location: location)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Fotos
                    if !currentEntry.photos.isEmpty {
                        PhotosGridView(photos: currentEntry.photos, store: viewModel.store)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Tags
                    if !currentEntry.tags.isEmpty {
                        TagsView(tags: currentEntry.tags)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    
                    // Resumo (se disponível)
                    if let summary = currentEntry.summary, !summary.isEmpty {
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
                        if #available(iOS 16.0, *) {
                            if let shareImageURL = generateShareImage() {
                                ShareLink(item: shareImageURL, preview: SharePreview(currentEntry.title.isEmpty ? "Entrada do Diário" : currentEntry.title)) {
                                    Label("Compartilhar", systemImage: "square.and.arrow.up")
                                }
                            } else {
                                ShareLink(item: ShareService.prepareShareText(for: currentEntry)) {
                                    Label("Compartilhar", systemImage: "square.and.arrow.up")
                                }
                            }
                        } else {
                            ShareLink(item: ShareService.prepareShareText(for: currentEntry)) {
                                Label("Compartilhar", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Button {
                            viewModel.loadEntry(currentEntry)
                            showingEditView = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button {
                            viewModel.deleteEntry(currentEntry)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                Text("Excluir")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EntryEditView(viewModel: viewModel)
            }
            .onChange(of: viewModel.store.entries) { _ in
                // Força atualização quando as entradas mudam
            }
        }
    }
    
    // MARK: - Private Methods
    
    @available(iOS 16.0, *)
    @MainActor
    private func generateShareImage() -> URL? {
        // Carrega imagens primeiro
        var loadedImages: [UIImage] = []
        for photo in currentEntry.photos {
            let fileURL = viewModel.store.photosDirectory.appendingPathComponent(photo.fileName)
            if let imageData = try? Data(contentsOf: fileURL),
               let image = UIImage(data: imageData) {
                loadedImages.append(image)
            }
        }
        
        // Cria view com imagens já carregadas
        let shareableView = ShareableEntryViewWithImages(entry: currentEntry, images: loadedImages)
        
        // Renderiza a imagem
        #if canImport(UIKit)
        let renderer = ImageRenderer(content: shareableView)
        renderer.scale = 3.0 // Alta resolução
        
        guard let image = renderer.uiImage,
              let imageData = image.pngData() else {
            // Erro ao renderizar imagem para compartilhamento
            return nil
        }
        
        // Salva temporariamente no diretório de fotos
        let fileName = "share_\(currentEntry.id.uuidString).png"
        let fileURL = viewModel.store.photosDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            // Erro ao salvar imagem para compartilhamento
            return nil
        }
        #else
        return nil
        #endif
    }
}

// MARK: - Previews Descomente para visualizar

//#Preview("Entry Detail - Com Localização") {
//    let store = EntryStore()
//    let viewModel = EntryViewModel(store: store)
//    let sampleEntry = Entry(
//        title: "Dia Incrível na Praia",
//        content: "Hoje foi um dia maravilhoso! Passei a tarde na praia com amigos, tomamos sol e nadamos muito. O pôr do sol estava simplesmente espetacular.",
//        location: Location(
//            name: "Praia de Copacabana",
//            latitude: -22.9711,
//            longitude: -43.1822,
//            address: "Copacabana, Rio de Janeiro - RJ"
//        ),
//        photos: [],
//        tags: ["praia", "amigos", "verão"]
//    )
//    
//    return EntryDetailView(entry: sampleEntry, viewModel: viewModel)
//}
//
//#Preview("Entry Detail - Com Fotos") {
//    let store = EntryStore()
//    let viewModel = EntryViewModel(store: store)
//    let sampleEntry = Entry(
//        title: "Viagem para Paris",
//        content: "Finalmente realizei o sonho de visitar Paris! A Torre Eiffel é ainda mais impressionante pessoalmente. Comi croissants deliciosos e caminhei pelas ruas charmosas da cidade.",
//        photos: [
//            Photo(fileName: "photo1.jpg", caption: "Torre Eiffel"),
//            Photo(fileName: "photo2.jpg", caption: "Café da manhã")
//        ],
//        tags: ["viagem", "paris", "turismo"]
//    )
//    
//    return EntryDetailView(entry: sampleEntry, viewModel: viewModel)
//}
//
