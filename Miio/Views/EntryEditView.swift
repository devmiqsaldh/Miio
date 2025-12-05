//
//  EntryEditView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI
import PhotosUI

/// View para criar ou editar uma entrada do diário
struct EntryEditView: View {
    @ObservedObject var viewModel: EntryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingLocationPicker = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content, tags
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Título
                Section {
                    TextField("Título", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .font(DesignSystem.Typography.title3())
                } header: {
                    Text("Título")
                }
                
                // Conteúdo
                Section {
                    TextEditor(text: $viewModel.content)
                        .focused($focusedField, equals: .content)
                        .frame(minHeight: 200)
                        .font(DesignSystem.Typography.body())
                } header: {
                    Text("Conteúdo")
                }
                
                // Fotos
                Section {
                    if !viewModel.selectedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.offset) { index, photo in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(DesignSystem.CornerRadius.small)
                                        
                                        Button {
                                            viewModel.selectedPhotos.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.xs)
                        }
                    }
                    
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Adicionar Fotos", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: viewModel.selectedPhotoItems) { newItems in
                        Task {
                            await loadSelectedPhotos(newItems)
                        }
                    }
                } header: {
                    Text("Fotos")
                }
                
                // Localização
                Section {
                    if let location = viewModel.currentLocation {
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(location.name)
                                    .font(DesignSystem.Typography.bodyBold())
                                if let address = location.address {
                                    Text(address)
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                viewModel.currentLocation = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                    } else {
                        Button {
                            viewModel.fetchCurrentLocation()
                        } label: {
                            HStack {
                                if viewModel.isLoadingLocation {
                                    ProgressView()
                                } else {
                                    Label("Adicionar Localização", systemImage: "location.fill")
                                }
                            }
                        }
                        .disabled(viewModel.isLoadingLocation)
                    }
                } header: {
                    Text("Localização")
                }
                
                // Tags
                Section {
                    TextField("Tags (separadas por vírgula)", text: $viewModel.tags)
                        .focused($focusedField, equals: .tags)
                        .font(DesignSystem.Typography.body())
                    
                    if !viewModel.content.isEmpty {
                        Button {
                            Task {
                                await viewModel.generateTagsAutomatically()
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text("Gerar Tags Automaticamente")
                            }
                        }
                        .disabled(viewModel.isProcessingAI)
                    }
                } header: {
                    Text("Tags")
                } footer: {
                    Text("Separe múltiplas tags com vírgulas ou use IA para gerar automaticamente")
                        .font(DesignSystem.Typography.caption())
                }
                
                // Foundation Models - Funcionalidades IA
                if !viewModel.content.isEmpty {
                    Section {
                        Button {
                            Task {
                                await viewModel.generateSummary()
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "text.bubble")
                                }
                                Text("Gerar Resumo")
                            }
                        }
                        .disabled(viewModel.isProcessingAI)
                        
                        Button {
                            Task {
                                let entities = await viewModel.extractEntities()
                                if !entities.isEmpty {
                                    viewModel.tags = (viewModel.tags.isEmpty ? "" : viewModel.tags + ", ") + entities.joined(separator: ", ")
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.2")
                                }
                                Text("Extrair Pessoas e Lugares")
                            }
                        }
                        .disabled(viewModel.isProcessingAI)
                        
                        Button {
                            Task {
                                let sentiment = await viewModel.classifySentiment()
                                // Adiciona como tag
                                if !viewModel.tags.contains(sentiment) {
                                    viewModel.tags = (viewModel.tags.isEmpty ? "" : viewModel.tags + ", ") + sentiment
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "face.smiling")
                                }
                                Text("Analisar Sentimento")
                            }
                        }
                        .disabled(viewModel.isProcessingAI)
                    } header: {
                        Text("Inteligência Artificial")
                    } footer: {
                        Text("Use IA para melhorar sua entrada")
                            .font(DesignSystem.Typography.caption())
                    }
                }
            }
            .navigationTitle(viewModel.currentEntry == nil ? "Nova Entrada" : "Editar Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .disabled(viewModel.title.isEmpty && viewModel.content.isEmpty)
                }
            }
            .onAppear {
                if viewModel.currentEntry == nil {
                    focusedField = .title
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        var loadedImages: [UIImage] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loadedImages.append(image)
            }
        }
        
        await MainActor.run {
            viewModel.selectedPhotos.append(contentsOf: loadedImages)
            viewModel.selectedPhotoItems = []
        }
    }
}

// MARK: - Previews

#Preview("Nova Entrada") {
    let store = EntryStore()
    let viewModel = EntryViewModel(store: store)
    viewModel.createNewEntry()
    
    return EntryEditView(viewModel: viewModel)
}

#Preview("Editar Entrada") {
    let store = EntryStore()
    let viewModel = EntryViewModel(store: store)
    let sampleEntry = Entry(
        title: "Minha Entrada",
        content: "Este é o conteúdo da minha entrada do diário.",
        tags: ["pessoal", "reflexão"]
    )
    viewModel.loadEntry(sampleEntry)
    
    return EntryEditView(viewModel: viewModel)
}

