//
//  EntryStore.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import Combine

/// Gerenciador de persistência e estado das entradas do diário
@MainActor
class EntryStore: ObservableObject {
    /// Array observável de todas as entradas
    @Published var entries: [Entry] = []
    
    /// Entrada atualmente selecionada
    @Published var selectedEntry: Entry?
    
    private let storageKey = "miio_entries"
    private let fileManager = FileManager.default
    
    /// Diretório para armazenar fotos
    var photosDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")
        
        if !fileManager.fileExists(atPath: photosPath.path) {
            try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        }
        
        return photosPath
    }
    
    init() {
        loadEntries()
    }
    
    /// Carrega entradas do armazenamento persistente
    func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Entry].self, from: data) else {
            entries = []
            return
        }
        entries = decoded.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Salva entradas no armazenamento persistente
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    /// Adiciona uma nova entrada
    /// - Parameter entry: Entrada a ser adicionada
    func addEntry(_ entry: Entry) {
        entries.insert(entry, at: 0)
        saveEntries()
    }
    
    /// Atualiza uma entrada existente
    /// - Parameter entry: Entrada atualizada
    func updateEntry(_ entry: Entry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        var updatedEntry = entry
        updatedEntry.updateModifiedDate()
        entries[index] = updatedEntry
        saveEntries()
    }
    
    /// Remove uma entrada
    /// - Parameter entry: Entrada a ser removida
    func deleteEntry(_ entry: Entry) {
        // Remove fotos associadas
        entry.photos.forEach { photo in
            let photoURL = photosDirectory.appendingPathComponent(photo.fileName)
            try? fileManager.removeItem(at: photoURL)
        }
        
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    /// Busca entradas por termo
    /// - Parameter searchText: Texto de busca
    /// - Returns: Array de entradas filtradas
    func searchEntries(_ searchText: String) -> [Entry] {
        guard !searchText.isEmpty else { return entries }
        let lowercased = searchText.lowercased()
        return entries.filter { entry in
            entry.title.lowercased().contains(lowercased) ||
            entry.content.lowercased().contains(lowercased) ||
            entry.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }
    
    /// Filtra entradas por tag
    /// - Parameter tag: Tag para filtrar
    /// - Returns: Array de entradas filtradas
    func filterByTag(_ tag: String) -> [Entry] {
        entries.filter { $0.tags.contains(tag) }
    }
}
