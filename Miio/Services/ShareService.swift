//
//  ShareService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import UIKit
import SwiftUI

/// Serviço responsável por compartilhar entradas em redes sociais
class ShareService {
    /// Compartilha uma entrada do diário
    /// - Parameters:
    ///   - entry: Entrada a ser compartilhada
    ///   - images: Imagens associadas
    ///   - sourceView: View de origem para apresentar o sheet (iPad)
    /// - Returns: UIActivityViewController configurado
    func shareEntry(_ entry: Entry, images: [UIImage], sourceView: UIView? = nil) -> UIActivityViewController {
        var items: [Any] = []
        
        // Texto da entrada
        var shareText = "📔 \(entry.title)\n\n\(entry.content)"
        
        if let location = entry.location {
            shareText += "\n\n📍 \(location.name)"
        }
        
        if !entry.tags.isEmpty {
            shareText += "\n\n🏷️ \(entry.tags.joined(separator: ", "))"
        }
        
        items.append(shareText)
        
        // Imagens
        items.append(contentsOf: images)
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Configurações para iPad
        if let popover = activityVC.popoverPresentationController, let sourceView = sourceView {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        // Exclui atividades não desejadas
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList
        ]
        
        return activityVC
    }
    
    /// Compartilha texto simples
    /// - Parameter text: Texto a ser compartilhado
    /// - Returns: UIActivityViewController configurado
    func shareText(_ text: String) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityVC
    }
    
    /// Compartilha imagens
    /// - Parameter images: Imagens a serem compartilhadas
    /// - Returns: UIActivityViewController configurado
    func shareImages(_ images: [UIImage]) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
        return activityVC
    }
}

/// Wrapper SwiftUI para apresentar o share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

