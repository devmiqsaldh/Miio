//
//  EntryListView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// View principal que exibe a lista de entradas do diário
struct EntryListView: View {
    @StateObject private var viewModel: EntryViewModel
    @State private var showingNewEntry = false
    @State private var selectedEntry: Entry?
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    init(store: EntryStore) {
        _viewModel = StateObject(wrappedValue: EntryViewModel(store: store))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if viewModel.filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    entriesList
                }
            }
            .navigationTitle("Meu Diário")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createNewEntry()
                        showingNewEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.allTags.isEmpty {
                        Menu {
                            Button("Todas as entradas") {
                                viewModel.selectedTag = nil
                            }
                            
                            Divider()
                            
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                Button(tag) {
                                    viewModel.selectedTag = tag
                                }
                            }
                        } label: {
                            Image(systemName: "tag.fill")
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Buscar entradas...")
            .sheet(isPresented: $showingNewEntry) {
                EntryEditView(viewModel: viewModel)
            }
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry, viewModel: viewModel)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: shareItems)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var entriesList: some View {
        List {
            ForEach(viewModel.filteredEntries.filter { !$0.tags.contains("arquivado") }) { entry in
                EntryCard(entry: entry) {
                    selectedEntry = entry
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: DesignSystem.Spacing.xs, leading: DesignSystem.Spacing.md, bottom: DesignSystem.Spacing.xs, trailing: DesignSystem.Spacing.md))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteEntry(entry)
                        }
                    } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                    
                    Button {
                        // Arquivar entrada (marcar como arquivada)
                        var archivedEntry = entry
                        if !archivedEntry.tags.contains("arquivado") {
                            archivedEntry.tags.append("arquivado")
                            viewModel.store.updateEntry(archivedEntry)
                        }
                    } label: {
                        Label("Arquivar", systemImage: "archivebox")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .animateAppearance(true)
            
            Text("Nenhuma entrada ainda")
                .font(DesignSystem.Typography.title2())
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .animateAppearance(true)
            
            Text("Toque no botão + para criar sua primeira entrada")
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .animateAppearance(true)
            
            Button {
                viewModel.createNewEntry()
                showingNewEntry = true
            } label: {
                Label("Nova Entrada", systemImage: "plus.circle.fill")
            }
            .primaryButtonStyle()
            .animateAppearance(true)
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

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
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location.name)
                            .font(DesignSystem.Typography.caption())
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
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

#Preview("Lista Vazia") {
    EntryListView(store: EntryStore())
}

#Preview("Lista com Entradas") {
    let store = EntryStore()
    
    // Adiciona entradas de exemplo
    let entries = [
        Entry(
            title: "Dia na Praia",
            content: "Passei um dia incrível na praia com amigos. O sol estava perfeito e a água estava deliciosa.",
            location: Location(name: "Praia de Copacabana", latitude: -22.9711, longitude: -43.1822),
            tags: ["praia", "amigos", "verão"]
        ),
        Entry(
            title: "Reflexão sobre a Vida",
            content: "Hoje refleti sobre as coisas importantes da vida. A família, os amigos e os momentos simples são o que realmente importam.",
            tags: ["reflexão", "pessoal"]
        ),
        Entry(
            title: "Nova Receita Testada",
            content: "Testei uma nova receita de bolo de chocolate hoje. Ficou delicioso! Vou fazer novamente no próximo fim de semana.",
            tags: ["culinária", "receita"]
        )
    ]
    
    entries.forEach { store.addEntry($0) }
    
    return EntryListView(store: store)
}

#Preview("Entry Card") {
    let entry = Entry(
        title: "Título da Entrada",
        content: "Este é um exemplo de conteúdo de uma entrada do diário. Pode conter várias linhas de texto para descrever o que aconteceu no dia.",
        location: Location(name: "Localização Exemplo", latitude: 0, longitude: 0),
        photos: [Photo(fileName: "photo.jpg")],
        tags: ["tag1", "tag2", "tag3"]
    )
    
    return EntryCard(entry: entry) {
        print("Card tapped")
    }
    .padding()
}

