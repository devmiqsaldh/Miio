//
//  FoundationModelsService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import NaturalLanguage

/// Serviço para interagir com Foundation Models (Apple Intelligence)
@MainActor
class FoundationModelsService {
    /// Resumo uma entrada do diário
    /// - Parameter content: Conteúdo a ser resumido
    /// - Returns: Resumo gerado ou nil em caso de erro
    func summarizeEntry(_ content: String) async -> String? {
        guard !content.isEmpty else { return nil }
        
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard sentences.count > 1 else { return nil }
        
        let summaryCount = min(3, sentences.count)
        let summarySentences = Array(sentences.prefix(summaryCount))
        return summarySentences.joined(separator: ". ") + "."
    }
    
    /// Extrai entidades (pessoas, lugares) de um texto usando NSLinguisticTagger
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de entidades encontradas
    func extractEntities(from content: String) async -> [String] {
        guard !content.isEmpty else { return [] }
        
        var entities: [String] = []
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = content
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let range = content.startIndex..<content.endIndex
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag {
                switch tag {
                case .personalName, .placeName, .organizationName:
                    let entity = String(content[tokenRange]).trimmingCharacters(in: .whitespaces)
                    if !entity.isEmpty && entity.count > 2 && !entities.contains(entity) {
                        entities.append(entity)
                    }
                default:
                    break
                }
            }
            return true
        }
        
        return Array(entities.prefix(10))
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
        // Por enquanto, aplica transformações básicas baseadas na instrução
        
        let lowerInstruction = instruction.lowercased()
        
        if lowerInstruction.contains("segunda pessoa") {
            return content.replacingOccurrences(of: "eu ", with: "você ", options: .caseInsensitive)
                .replacingOccurrences(of: "Eu ", with: "Você ", options: .caseInsensitive)
                .replacingOccurrences(of: "meu ", with: "seu ", options: .caseInsensitive)
                .replacingOccurrences(of: "minha ", with: "sua ", options: .caseInsensitive)
        }
        
        return content
    }
    
}

