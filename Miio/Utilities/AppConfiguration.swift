//
//  AppConfiguration.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import CoreLocation

/// Configurações e utilitários do aplicativo
enum AppConfiguration {
    /// Nome do aplicativo
    static let appName = "Miio"
    
    /// Versão do aplicativo
    static let appVersion = "1.0.0"
    
    /// Chave para armazenamento de entradas
    static let entriesStorageKey = "miio_entries"
    
    /// Diretório de fotos
    static var photosDirectoryName: String {
        "Photos"
    }
    
    /// Verifica se as permissões necessárias estão configuradas
    /// - Returns: Array de permissões que precisam ser solicitadas
    static func checkRequiredPermissions() -> [PermissionType] {
        var missingPermissions: [PermissionType] = []
        
        // Verifica permissão de localização
        let locationStatus = CLLocationManager().authorizationStatus
        if locationStatus == .notDetermined || locationStatus == .denied {
            missingPermissions.append(.location)
        }
        
        // Nota: Permissão de fotos é solicitada em tempo de execução via PhotosPicker
        // Não há necessidade de verificar antecipadamente
        
        return missingPermissions
    }
}

/// Tipos de permissões necessárias
enum PermissionType {
    case location
    case photos
    
    /// Mensagem descritiva da permissão
    var description: String {
        switch self {
        case .location:
            return "Localização é necessária para adicionar lugares às suas entradas"
        case .photos:
            return "Acesso às fotos é necessário para adicionar imagens às suas entradas"
        }
    }
}

