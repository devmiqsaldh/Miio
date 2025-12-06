//
//  EntryEditView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI
import PhotosUI

// UIImage necessário apenas para processamento de dados de imagem
#if canImport(UIKit)
import UIKit
#endif

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
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                Form {
                    // Título
                    Section {
                        TextField("Título", text: $viewModel.title)
                            .focused($focusedField, equals: .title)
                            .font(DesignSystem.Typography.title3())
                            .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    } header: {
                        Text("Título")
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                
                // Conteúdo
                Section {
                    TextEditor(text: $viewModel.content)
                        .focused($focusedField, equals: .content)
                        .frame(minHeight: 200)
                        .font(DesignSystem.Typography.body())
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                } header: {
                    Text("Conteúdo")
                        .foregroundColor(DesignSystem.Colors.textPrimary)
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
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    .tint(DesignSystem.Colors.textPrimary)
                    .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    .onChange(of: viewModel.selectedPhotoItems) { _ in
                        Task {
                            await viewModel.loadSelectedPhotos()
                        }
                    }
                } header: {
                    Text("Fotos")
                        .foregroundColor(DesignSystem.Colors.textPrimary)
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
                                viewModel.locationSearchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    } else {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            TextField("Buscar localização...", text: $viewModel.locationSearchText)
                                .font(DesignSystem.Typography.body())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .onChange(of: viewModel.locationSearchText) { newValue in
                                    if !newValue.isEmpty {
                                        viewModel.searchLocations(query: newValue)
                                    } else {
                                        viewModel.locationSearchResults = []
                                    }
                                }
                                .listRowBackground(DesignSystem.Colors.secondaryBackground)
                            
                            // Botão para usar GPS
                            Button {
                                viewModel.fetchCurrentLocation()
                            } label: {
                                HStack {
                                    if viewModel.isLoadingLocation {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(DesignSystem.Colors.textPrimary)
                                    } else {
                                        Label("Usar minha localização", systemImage: "location.fill")
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                    }
                                }
                            }
                            .disabled(viewModel.isLoadingLocation)
                            .tint(DesignSystem.Colors.textPrimary)
                            
                            // Resultados da busca
                            if viewModel.isSearchingLocation {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(DesignSystem.Colors.textPrimary)
                                    Text("Buscando...")
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            } else if !viewModel.locationSearchResults.isEmpty {
                                ForEach(Array(viewModel.locationSearchResults.enumerated()), id: \.offset) { index, location in
                                    Button {
                                        viewModel.selectLocation(location)
                                    } label: {
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
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .tint(DesignSystem.Colors.textPrimary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Localização")
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                // Tags
                Section {
                    TextField("Tags (separadas por vírgula)", text: $viewModel.tags)
                        .focused($focusedField, equals: .tags)
                        .font(DesignSystem.Typography.body())
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    
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
                                        .tint(DesignSystem.Colors.textPrimary)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text("Gerar Tags Automaticamente")
                            }
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .disabled(viewModel.isProcessingAI)
                        .tint(DesignSystem.Colors.textPrimary)
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    }
                } header: {
                    Text("Tags")
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                } footer: {
                    Text("Separe múltiplas tags com vírgulas ou use IA para gerar automaticamente")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // Inteligência Artificial
                if !viewModel.content.isEmpty {
                    Section {
                        Button {
                            Task {
                                if let summary = await viewModel.generateSummary() {
                                    viewModel.content = summary
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(DesignSystem.Colors.textPrimary)
                                } else {
                                    Image(systemName: "text.bubble")
                                }
                                Text("Gerar Resumo")
                            }
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .disabled(viewModel.isProcessingAI)
                        .tint(DesignSystem.Colors.textPrimary)
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                        
                        Button {
                            Task {
                                await viewModel.extractEntitiesAndAddToTags()
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingAI {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(DesignSystem.Colors.textPrimary)
                                } else {
                                    Image(systemName: "person.2")
                                }
                                Text("Extrair Pessoas e Lugares")
                            }
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .disabled(viewModel.isProcessingAI)
                        .tint(DesignSystem.Colors.textPrimary)
                        .listRowBackground(DesignSystem.Colors.secondaryBackground)
                    } header: {
                        Text("Inteligência Artificial")
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                }
                .scrollContentBackground(.hidden)
                .background(DesignSystem.Colors.background)
                .listRowBackground(DesignSystem.Colors.secondaryBackground)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.currentEntry == nil ? "Nova Entrada" : "Editar Entrada")
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
            .onDisappear {
                // Reseta o formulário ao sair se não foi salvo
                if viewModel.currentEntry == nil {
                    viewModel.createNewEntry()
                }
            }
        }
    }
}

// MARK: - Previews Descomente para visualizar

//#Preview("Nova Entrada") {
//    let store = EntryStore()
//    let viewModel = EntryViewModel(store: store)
//    viewModel.createNewEntry()
//    
//    return EntryEditView(viewModel: viewModel)
//}
//
//#Preview("Editar Entrada") {
//    let store = EntryStore()
//    let viewModel = EntryViewModel(store: store)
//    let sampleEntry = Entry(
//        title: "Minha Entrada",
//        content: "Este é o conteúdo da minha entrada do diário.",
//        tags: ["pessoal", "reflexão"]
//    )
//    viewModel.loadEntry(sampleEntry)
//    
//    return EntryEditView(viewModel: viewModel)
//}
