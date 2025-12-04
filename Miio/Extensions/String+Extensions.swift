//
//  String+Extensions.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation

/// Extensões úteis para String
extension String {
    /// Remove espaços em branco no início e fim
    /// - Returns: String sem espaços nas extremidades
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Verifica se a string não está vazia após remover espaços
    /// - Returns: True se não estiver vazia
    var isNotEmpty: Bool {
        !self.trimmed().isEmpty
    }
    
    /// Extrai tags de uma string separada por vírgulas
    /// - Returns: Array de tags limpas
    func extractTags() -> [String] {
        self.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    /// Limita o tamanho da string
    /// - Parameter length: Tamanho máximo
    /// - Returns: String truncada se necessário
    func truncated(to length: Int) -> String {
        guard self.count > length else { return self }
        return String(self.prefix(length)) + "..."
    }
}

