//
//  FoundationModelsService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation

/// Serviço para interagir com Foundation Models (Apple Intelligence)
@MainActor
class FoundationModelsService {
    /// Resumo uma entrada do diário
    /// - Parameter content: Conteúdo a ser resumido
    /// - Returns: Resumo gerado ou nil em caso de erro
    func summarizeEntry(_ content: String) async -> String? {
        // Nota: Em produção, isso usaria o framework Foundation Models da Apple
        // Por enquanto, retorna um resumo simples baseado em heurísticas
        
        guard content.count > 100 else { return nil }
        
        let sentences = content.components(separatedBy: ". ")
        guard sentences.count > 2 else { return nil }
        
        // Retorna as primeiras 2-3 frases como resumo
        let summarySentences = Array(sentences.prefix(3))
        return summarySentences.joined(separator: ". ") + "."
    }
    
    /// Extrai entidades (pessoas, lugares) de um texto
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de entidades encontradas
    func extractEntities(from content: String) async -> [String] {
        // Em produção, usaria NSLinguisticTagger ou Foundation Models
        // Por enquanto, retorna palavras capitalizadas que podem ser entidades
        
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { word in
            word.count > 3 && 
            word.first?.isUppercase == true &&
            !word.lowercased().hasPrefix("o ") &&
            !word.lowercased().hasPrefix("a ") &&
            !word.lowercased().hasPrefix("de ") &&
            !word.lowercased().hasPrefix("da ")
        }
        .prefix(5)
        .map { $0.trimmingCharacters(in: .punctuationCharacters) }
    }
    
    /// Gera tags a partir de um texto
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de tags sugeridas
    func generateTags(from content: String) async -> [String] {
        // Em produção, usaria análise semântica avançada
        // Por enquanto, retorna palavras-chave baseadas em frequência
        
        let words = content.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { $0.count > 4 }
        
        let wordFrequency = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(wordFrequency.prefix(3).map { $0.key })
    }
    
    /// Classifica o sentimento de um texto
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Sentimento detectado (positivo, neutro, negativo)
    func classifySentiment(_ content: String) async -> String {
        // Em produção, usaria análise de sentimento avançada
        let positiveWords = ["feliz", "ótimo", "bom", "amor", "alegria", "sucesso"]
        let negativeWords = ["triste", "ruim", "problema", "difícil", "frustrado"]
        
        let lowercased = content.lowercased()
        let positiveCount = positiveWords.filter { lowercased.contains($0) }.count
        let negativeCount = negativeWords.filter { lowercased.contains($0) }.count
        
        if positiveCount > negativeCount {
            return "positivo"
        } else if negativeCount > positiveCount {
            return "negativo"
        } else {
            return "neutro"
        }
    }
    
    /// Refina ou edita um texto
    /// - Parameters:
    ///   - content: Conteúdo original
    ///   - instruction: Instrução de como modificar (ex: "segunda pessoa")
    /// - Returns: Texto refinado
    func refineText(_ content: String, instruction: String) async -> String {
        // Em produção, usaria Foundation Models para transformações complexas
        // Por enquanto, retorna o texto original
        return content
    }
}

