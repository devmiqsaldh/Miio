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
            .background(DesignSystem.Colors.background)
            .navigationTitle(viewModel.showingArchived ? "Arquivadas" : "Meu Diário")
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
                    Menu {
                        // Toggle para mostrar arquivados
                        Button {
                            withAnimation {
                                viewModel.showingArchived.toggle()
                                viewModel.selectedTag = nil
                            }
                        } label: {
                            HStack {
                                Text(viewModel.showingArchived ? "Mostrar Ativas" : "Mostrar Arquivadas")
                                if viewModel.showingArchived {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        if !viewModel.showingArchived && viewModel.archivedCount > 0 {
                            Text("\(viewModel.archivedCount) arquivada\(viewModel.archivedCount > 1 ? "s" : "")")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        if !viewModel.allTags.isEmpty && !viewModel.showingArchived {
                            Divider()
                            
                            Button("Todas as entradas") {
                                viewModel.selectedTag = nil
                            }
                            
                            Divider()
                            
                            ForEach(viewModel.allTags.filter { $0 != "arquivado" }, id: \.self) { tag in
                                Button(tag) {
                                    viewModel.selectedTag = tag
                                }
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.showingArchived ? "archivebox.fill" : "tag.fill")
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
        }
    }
    
    // MARK: - Subviews
    
    private var entriesList: some View {
        List {
            ForEach(viewModel.filteredEntries) { entry in
                EntryCard(entry: entry) {
                    selectedEntry = entry
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: DesignSystem.Spacing.xs, leading: DesignSystem.Spacing.md, bottom: DesignSystem.Spacing.xs, trailing: DesignSystem.Spacing.md))
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if viewModel.showingArchived {
                        // Se está mostrando arquivados, permite desarquivar
                        Button {
                            withAnimation {
                                viewModel.unarchiveEntry(entry)
                            }
                        } label: {
                            Image(systemName: "tray.and.arrow.up")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .tint(DesignSystem.Colors.secondaryBackground)
                        
                        Button {
                            withAnimation {
                                viewModel.deleteEntry(entry)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .tint(DesignSystem.Colors.secondaryBackground)
                    } else {
                        // Se está mostrando ativas, permite arquivar
                        Button {
                            withAnimation {
                                viewModel.deleteEntry(entry)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .tint(DesignSystem.Colors.secondaryBackground)
                        
                        Button {
                            withAnimation {
                                viewModel.archiveEntry(entry)
                            }
                        } label: {
                            Image(systemName: "archivebox")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .tint(DesignSystem.Colors.secondaryBackground)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: viewModel.showingArchived ? "archivebox" : "book.closed")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .animateAppearance(true)
            
            Text(viewModel.showingArchived ? "Nenhuma entrada arquivada" : "Nenhuma entrada ainda")
                .font(DesignSystem.Typography.title2())
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .animateAppearance(true)
            
            Text(viewModel.showingArchived ? "As entradas arquivadas aparecerão aqui" : "Toque no botão + para criar sua primeira entrada")
                .font(DesignSystem.Typography.body())
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .animateAppearance(true)
            
            if !viewModel.showingArchived {
                Button {
                    viewModel.createNewEntry()
                    showingNewEntry = true
                } label: {
                    Label("Nova Entrada", systemImage: "plus.circle.fill")
                }
                .primaryButtonStyle()
                .animateAppearance(true)
            }
        }
        .padding(DesignSystem.Spacing.xl)
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

