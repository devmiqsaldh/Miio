//
//  ShareService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Serviço responsável por preparar conteúdo para compartilhamento usando SwiftUI
struct ShareService {
    /// Prepara o texto de compartilhamento de uma entrada
    /// - Parameter entry: Entrada a ser compartilhada
    /// - Returns: Texto formatado para compartilhamento
    static func prepareShareText(for entry: Entry) -> String {
        var shareText = entry.title.isEmpty ? "Entrada do Diário" : entry.title
        shareText += "\n\n\(entry.content)"
        
        if let location = entry.location {
            shareText += "\n\nLocalização: \(location.name)"
        }
        
        if !entry.tags.isEmpty {
            shareText += "\n\nTags: \(entry.tags.joined(separator: ", "))"
        }
        
        return shareText
    }
    
    /// Prepara os URLs das fotos para compartilhamento
    /// - Parameters:
    ///   - entry: Entrada a ser compartilhada
    ///   - store: Store para acessar as fotos
    /// - Returns: Array de URLs das fotos
    static func prepareShareItems(for entry: Entry, store: EntryStore) -> [URL] {
        var items: [URL] = []
        
        // Adiciona URLs das imagens
        for photo in entry.photos {
            let fileURL = store.photosDirectory.appendingPathComponent(photo.fileName)
            items.append(fileURL)
        }
        
        return items
    }
}
