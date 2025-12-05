//
//  EntryViewModel.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import SwiftUI
import CoreLocation
import PhotosUI
import UniformTypeIdentifiers
import Combine

// UIImage necessário apenas para processamento de dados de imagem
#if canImport(UIKit)
import UIKit
#endif

/// ViewModel responsável pela lógica de negócio das entradas do diário
@MainActor
class EntryViewModel: ObservableObject {
    /// Store de entradas
    @Published var store: EntryStore
    
    /// Entrada atual sendo editada/criada
    @Published var currentEntry: Entry?
    
    /// Título da entrada
    @Published var title: String = ""
    
    /// Conteúdo da entrada
    @Published var content: String = ""
    
    /// Tags da entrada (separadas por vírgula)
    @Published var tags: String = ""
    
    /// Localização atual
    @Published var currentLocation: Location?
    
    /// Fotos selecionadas
    #if canImport(UIKit)
    @Published var selectedPhotos: [UIImage] = []
    #else
    // Em plataformas sem UIKit, mantenha um placeholder vazio
    @Published var selectedPhotos: [Any] = []
    #endif
    
    /// Item de seleção de fotos do PhotosPicker
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    
    /// Texto de busca
    @Published var searchText: String = ""
    
    /// Tag selecionada para filtro
    @Published var selectedTag: String?
    
    /// Indica se está carregando localização
    @Published var isLoadingLocation: Bool = false
    
    /// Texto de busca de localização
    @Published var locationSearchText: String = ""
    
    /// Resultados da busca de localização
    @Published var locationSearchResults: [Location] = []
    
    /// Indica se está buscando localizações
    @Published var isSearchingLocation: Bool = false
    
    /// Indica se está processando Foundation Models
    @Published var isProcessingAI: Bool = false
    
    /// Indica se está mostrando arquivados
    @Published var showingArchived: Bool = false
    
    /// Serviço de Foundation Models
    private let foundationService = FoundationModelsService()
    
    /// Serviço do Gemini para geração de tags
    private let geminiService = GeminiService()
    
    /// Serviço de localização
    private let locationService = LocationService()
    
    /// Inicializa o ViewModel
    /// - Parameter store: Store de entradas
    init(store: EntryStore) {
        self.store = store
    }
    
    /// Carrega uma entrada para edição
    /// - Parameter entry: Entrada a ser carregada
    func loadEntry(_ entry: Entry) {
        currentEntry = entry
        title = entry.title
        content = entry.content
        tags = entry.tags.joined(separator: ", ")
        currentLocation = entry.location
        #if canImport(UIKit)
        selectedPhotos = loadPhotos(for: entry)
        #endif
    }
    
    /// Cria uma nova entrada
    func createNewEntry() {
        currentEntry = nil
        title = ""
        content = ""
        tags = ""
        currentLocation = nil
        locationSearchText = ""
        locationSearchResults = []
        #if canImport(UIKit)
        selectedPhotos = []
        #else
        selectedPhotos = []
        #endif
        selectedPhotoItems = []
    }
    
    /// Salva a entrada atual
    func saveEntry() {
        guard !title.isEmpty || !content.isEmpty else { return }
        
        // Evita uso de .trimmed() em Substring: converte para String e aplica trimmingCharacters
        let tagArray = tags.split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let photos = savePhotos()
        
        if var entry = currentEntry {
            entry.title = title
            entry.content = content
            entry.tags = tagArray
            entry.location = currentLocation
            entry.photos = photos
            store.updateEntry(entry)
            // Atualiza o currentEntry com a versão atualizada do store
            currentEntry = store.entries.first { $0.id == entry.id }
        } else {
            let newEntry = Entry(
                title: title,
                content: content,
                location: currentLocation,
                photos: photos,
                tags: tagArray
            )
            store.addEntry(newEntry)
        }
        
        createNewEntry()
    }
    
    /// Deleta uma entrada
    /// - Parameter entry: Entrada a ser deletada
    func deleteEntry(_ entry: Entry) {
        store.deleteEntry(entry)
    }
    
    /// Arquiva uma entrada
    /// - Parameter entry: Entrada a ser arquivada
    func archiveEntry(_ entry: Entry) {
        var archivedEntry = entry
        if !archivedEntry.tags.contains("arquivado") {
            archivedEntry.tags.append("arquivado")
            store.updateEntry(archivedEntry)
        }
    }
    
    /// Desarquiva uma entrada
    /// - Parameter entry: Entrada a ser desarquivada
    func unarchiveEntry(_ entry: Entry) {
        var unarchivedEntry = entry
        if let index = unarchivedEntry.tags.firstIndex(of: "arquivado") {
            unarchivedEntry.tags.remove(at: index)
            store.updateEntry(unarchivedEntry)
        }
    }
    
    /// Busca localizações baseado no texto digitado
    func searchLocations(query: String) {
        guard !query.isEmpty, query.count > 2 else {
            locationSearchResults = []
            return
        }
        
        isSearchingLocation = true
        locationService.searchLocations(query: query) { [weak self] locations in
            guard let self = self else { return }
            self.isSearchingLocation = false
            self.locationSearchResults = locations
        }
    }
    
    /// Seleciona uma localização dos resultados
    /// - Parameter location: Localização selecionada
    func selectLocation(_ location: Location) {
        currentLocation = location
        locationSearchText = location.name
        locationSearchResults = []
    }
    
    /// Busca a localização atual
    func fetchCurrentLocation() {
        isLoadingLocation = true
        locationService.requestCurrentLocation { [weak self] location in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoadingLocation = false
                
                guard let location = location else { return }
                
                self.locationService.reverseGeocodeLocation(location) { [weak self] formattedLocation in
                    self?.currentLocation = formattedLocation
                }
            }
        }
    }
    
    /// Entradas filtradas baseadas na busca, tag selecionada e status de arquivamento
    var filteredEntries: [Entry] {
        var result = store.entries
        
        // Filtra por status de arquivamento
        if showingArchived {
            result = result.filter { $0.tags.contains("arquivado") }
        } else {
            result = result.filter { !$0.tags.contains("arquivado") }
        }
        
        // Filtra por busca
        if !searchText.isEmpty {
            result = result.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filtra por tag selecionada (exceto "arquivado")
        if let tag = selectedTag, tag != "arquivado" {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        return result.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Conta de entradas arquivadas
    var archivedCount: Int {
        store.entries.filter { $0.tags.contains("arquivado") }.count
    }
    
    /// Todas as tags únicas de todas as entradas (exceto "arquivado")
    var allTags: [String] {
        Array(Set(store.entries.flatMap { $0.tags }.filter { $0 != "arquivado" })).sorted()
    }
    
    // MARK: - Foundation Models Methods
    
    /// Gera resumo da entrada atual
    func generateSummary() async -> String? {
        guard !content.isEmpty else { return nil }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.summarizeEntry(content)
    }
    
    /// Gera tags automaticamente a partir do conteúdo usando Gemini (com fallback)
    func generateTagsAutomatically() async {
        guard !content.isEmpty else { return }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        // Primeiro tenta Gemini
        var generatedTags = await geminiService.generateTags(from: content)
        
        // Fallback para Foundation Models se vier vazio
        if generatedTags.isEmpty {
            generatedTags = await foundationService.generateTags(from: content)
        }
        
        if !generatedTags.isEmpty {
            // Evita uso de .trimmed() em Substring
            let existingTags = tags.isEmpty
                ? []
                : tags.split(separator: ",")
                    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            let allTags = Array(Set(existingTags + generatedTags))
            tags = allTags.joined(separator: ", ")
        }
    }
    
    /// Extrai entidades do conteúdo e adiciona às tags
    func extractEntitiesAndAddToTags() async {
        guard !content.isEmpty else { return }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        let entities = await foundationService.extractEntities(from: content)
        guard !entities.isEmpty else { return }
        
        let existingTags = tags.isEmpty
            ? []
            : tags.split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        
        let allTags = Array(Set(existingTags + entities))
        tags = allTags.joined(separator: ", ")
    }
    
    // MARK: - Additional AI Methods (Available for future use)
    
    /// Extrai entidades do conteúdo (pessoas, lugares, organizações)
    /// - Returns: Array de entidades encontradas
    func extractEntities() async -> [String] {
        guard !content.isEmpty else { return [] }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.extractEntities(from: content)
    }
    
    /// Classifica o sentimento do conteúdo
    /// - Returns: Sentimento detectado ("positivo", "neutro" ou "negativo")
    func classifySentiment() async -> String {
        guard !content.isEmpty else { return "neutro" }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.classifySentiment(content)
    }
    
    /// Refina o texto conforme uma instrução
    /// - Parameter instruction: Instrução de como modificar o texto
    func refineText(instruction: String) async {
        guard !content.isEmpty else { return }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        content = await foundationService.refineText(content, instruction: instruction)
    }
    
    // MARK: - Private Methods
    
    /// Salva as fotos selecionadas e retorna array de Photo
    private func savePhotos() -> [Photo] {
        #if canImport(UIKit)
        var savedPhotos: [Photo] = []
        for image in selectedPhotos {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = store.photosDirectory.appendingPathComponent(fileName)
            do {
                try imageData.write(to: fileURL)
                let photo = Photo(fileName: fileName, capturedAt: Date())
                savedPhotos.append(photo)
            } catch {
                // Erro ao salvar foto é silenciado para não interromper o fluxo
            }
        }
        return savedPhotos
        #else
        return []
        #endif
    }
    
    /// Carrega fotos de uma entrada
    #if canImport(UIKit)
    private func loadPhotos(for entry: Entry) -> [UIImage] {
        entry.photos.compactMap { photo in
            let fileURL = store.photosDirectory.appendingPathComponent(photo.fileName)
            guard let imageData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        }
    }
    
    /// Carrega fotos selecionadas do PhotosPicker
    func loadSelectedPhotos() async {
        var loadedImages: [UIImage] = []
        
        for item in selectedPhotoItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loadedImages.append(image)
            }
        }
        
        await MainActor.run {
            selectedPhotos.append(contentsOf: loadedImages)
            selectedPhotoItems = []
        }
    }
    #endif
}
