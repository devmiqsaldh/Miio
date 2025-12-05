//
//  Entry.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import CoreLocation

/// Modelo principal que representa uma entrada do diário
struct Entry: Identifiable, Codable, Equatable {
    /// Identificador único da entrada
    let id: UUID
    
    /// Título da entrada
    var title: String
    
    /// Conteúdo textual da entrada
    var content: String
    
    /// Data de criação da entrada
    var createdAt: Date
    
    /// Data da última modificação
    var modifiedAt: Date
    
    /// Localização associada à entrada
    var location: Location?
    
    /// Fotos associadas à entrada
    var photos: [Photo]
    
    /// Tags para categorização
    var tags: [String]
    
    /// Resumo gerado automaticamente (opcional)
    var summary: String?
    
    /// Inicializa uma nova entrada do diário
    /// - Parameters:
    ///   - id: Identificador único (gerado automaticamente se nil)
    ///   - title: Título da entrada
    ///   - content: Conteúdo textual
    ///   - createdAt: Data de criação (padrão: agora)
    ///   - modifiedAt: Data de modificação (padrão: agora)
    ///   - location: Localização opcional
    ///   - photos: Array de fotos
    ///   - tags: Tags de categorização
    ///   - summary: Resumo gerado automaticamente
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        location: Location? = nil,
        photos: [Photo] = [],
        tags: [String] = [],
        summary: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.location = location
        self.photos = photos
        self.tags = tags
        self.summary = summary
    }
    
    /// Atualiza a data de modificação para o momento atual
    mutating func updateModifiedDate() {
        self.modifiedAt = Date()
    }
}

/// Modelo que representa uma localização geográfica
struct Location: Codable, Equatable {
    /// Nome do lugar
    var name: String
    
    /// Latitude
    var latitude: Double
    
    /// Longitude
    var longitude: Double
    
    /// Endereço completo (opcional)
    var address: String?
    
    /// Inicializa uma localização
    /// - Parameters:
    ///   - name: Nome do lugar
    ///   - latitude: Latitude
    ///   - longitude: Longitude
    ///   - address: Endereço completo
    init(name: String, latitude: Double, longitude: Double, address: String? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    /// Converte para CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Inicializa a partir de CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D, name: String, address: String? = nil) {
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
}

/// Modelo que representa uma foto associada a uma entrada
struct Photo: Identifiable, Codable, Equatable {
    /// Identificador único da foto
    let id: UUID
    
    /// Nome do arquivo da foto
    var fileName: String
    
    /// Data de captura
    var capturedAt: Date
    
    /// Descrição opcional da foto
    var caption: String?
    
    /// Inicializa uma nova foto
    /// - Parameters:
    ///   - id: Identificador único
    ///   - fileName: Nome do arquivo
    ///   - capturedAt: Data de captura
    ///   - caption: Descrição opcional
    init(id: UUID = UUID(), fileName: String, capturedAt: Date = Date(), caption: String? = nil) {
        self.id = id
        self.fileName = fileName
        self.capturedAt = capturedAt
        self.caption = caption
    }
}

