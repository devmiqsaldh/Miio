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
import UIKit

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
    @Published var selectedPhotos: [UIImage] = []
    
    /// Item de seleção de fotos do PhotosPicker
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    
    /// Texto de busca
    @Published var searchText: String = ""
    
    /// Tag selecionada para filtro
    @Published var selectedTag: String?
    
    /// Indica se está carregando localização
    @Published var isLoadingLocation: Bool = false
    
    /// Indica se está processando Foundation Models
    @Published var isProcessingAI: Bool = false
    
    /// Serviço de Foundation Models
    private let foundationService = FoundationModelsService()
    
    /// Serviço do Gemini
    private let geminiService = GeminiService()
    
    /// Gerenciador de localização
    private let locationManager = LocationManager()
    
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
        selectedPhotos = loadPhotos(for: entry)
    }
    
    /// Cria uma nova entrada
    func createNewEntry() {
        currentEntry = nil
        title = ""
        content = ""
        tags = ""
        currentLocation = nil
        selectedPhotos = []
        selectedPhotoItems = []
    }
    
    /// Salva a entrada atual
    func saveEntry() {
        guard !title.isEmpty || !content.isEmpty else { return }
        
        let tagArray = tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let photos = savePhotos()
        
        if var entry = currentEntry {
            // Atualiza entrada existente
            entry.title = title
            entry.content = content
            entry.tags = tagArray
            entry.location = currentLocation
            entry.photos = photos
            store.updateEntry(entry)
        } else {
            // Cria nova entrada
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
    
    /// Busca a localização atual
    func fetchCurrentLocation() {
        isLoadingLocation = true
        locationManager.requestLocation { [weak self] location in
            Task { @MainActor in
                self?.isLoadingLocation = false
                if let location = location {
                    self?.currentLocation = Location(
                        coordinate: location.coordinate,
                        name: "Localização atual",
                        address: nil
                    )
                }
            }
        }
    }
    
    /// Entradas filtradas baseadas na busca e tag selecionada
    var filteredEntries: [Entry] {
        var result = store.entries
        
        if !searchText.isEmpty {
            result = store.searchEntries(searchText)
        }
        
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        return result
    }
    
    /// Todas as tags únicas de todas as entradas
    var allTags: [String] {
        Array(Set(store.entries.flatMap { $0.tags })).sorted()
    }
    
    // MARK: - Foundation Models Methods
    
    /// Gera resumo da entrada atual
    func generateSummary() async -> String? {
        guard !content.isEmpty else { return nil }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.summarizeEntry(content)
    }
    
    /// Gera tags automaticamente a partir do conteúdo usando Gemini
    func generateTagsAutomatically() async {
        guard !content.isEmpty else { return }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        // Tenta usar Gemini primeiro
        var generatedTags = await geminiService.generateTags(from: content)
        
        // Se Gemini não retornar, usa Foundation Models como fallback
        if generatedTags.isEmpty {
            generatedTags = await foundationService.generateTags(from: content)
        }
        
        if !generatedTags.isEmpty {
            let existingTags = tags.isEmpty
                ? []
                : tags.split(separator: ",")
                    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            let allTags = Array(Set(existingTags + generatedTags))
            tags = allTags.joined(separator: ", ")
        }
    }
    
    /// Extrai entidades do conteúdo
    func extractEntities() async -> [String] {
        guard !content.isEmpty else { return [] }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.extractEntities(from: content)
    }
    
    /// Classifica o sentimento do conteúdo
    func classifySentiment() async -> String {
        guard !content.isEmpty else { return "neutro" }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        return await foundationService.classifySentiment(content)
    }
    
    /// Refina o texto com uma instrução
    /// - Parameter instruction: Instrução de como refinar
    func refineText(instruction: String) async {
        guard !content.isEmpty else { return }
        isProcessingAI = true
        defer { isProcessingAI = false }
        
        content = await foundationService.refineText(content, instruction: instruction)
    }
    
    // MARK: - Private Methods
    
    /// Salva as fotos selecionadas e retorna array de Photo
    private func savePhotos() -> [Photo] {
        var savedPhotos: [Photo] = []
        
        for (_, image) in selectedPhotos.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = store.photosDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                let photo = Photo(fileName: fileName, capturedAt: Date())
                savedPhotos.append(photo)
            } catch {
                print("Erro ao salvar foto: \(error)")
            }
        }
        
        return savedPhotos
    }
    
    /// Carrega fotos de uma entrada
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
}

/// Gerenciador de localização
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Solicita a localização atual
    /// - Parameter completion: Callback com a localização ou nil
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion(nil)
        @unknown default:
            completion(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?(nil)
            completion = nil
            return
        }
        completion?(location)
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter localização: \(error.localizedDescription)")
        completion?(nil)
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            completion?(nil)
            completion = nil
        }
    }
}
