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
        
        // Usa NLTagger para dividir em sentenças de forma mais precisa
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = content
        
        var sentences: [String] = []
        var currentSentence = ""
        
        // Configura o idioma se possível
        if let language = NLLanguageRecognizer.dominantLanguage(for: content) {
            tagger.setLanguage(language, range: content.startIndex..<content.endIndex)
        }
        
        let range = content.startIndex..<content.endIndex
        
        // Enumerar por sentenças
        tagger.enumerateTags(in: range, unit: .sentence, scheme: .tokenType, options: []) { tag, tokenRange in
            let sentence = String(content[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty && sentence.count > 10 {
                sentences.append(sentence)
            }
            return true
        }
        
        // Se não encontrou sentenças com NLTagger, usa método alternativo
        if sentences.isEmpty {
            // Divide por pontuação de forma mais robusta
            let separators = CharacterSet(charactersIn: ".!?\n")
            sentences = content.components(separatedBy: separators)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 10 }
        }
        
        guard !sentences.isEmpty else {
            // Se não conseguiu dividir em sentenças, retorna as primeiras palavras
            let words = content.components(separatedBy: .whitespaces)
            if words.count > 20 {
                let summaryWords = Array(words.prefix(20))
                return summaryWords.joined(separator: " ") + "..."
            }
            return content
        }
        
        // Se tiver apenas uma sentença longa, pega as primeiras palavras
        if sentences.count == 1 && sentences[0].count > 100 {
            let words = sentences[0].components(separatedBy: .whitespaces)
            let summaryWords = Array(words.prefix(min(30, words.count)))
            return summaryWords.joined(separator: " ") + "..."
        }
        
        // Pega as primeiras 2-3 sentenças como resumo
        let summaryCount = min(3, max(1, sentences.count))
        let summarySentences = Array(sentences.prefix(summaryCount))
        let summary = summarySentences.joined(separator: ". ")
        
        // Adiciona ponto final se não tiver
        if !summary.hasSuffix(".") && !summary.hasSuffix("!") && !summary.hasSuffix("?") {
            return summary + "."
        }
        
        return summary
    }
    
    /// Extrai entidades (pessoas, lugares) de um texto usando NLTagger
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de entidades encontradas
    func extractEntities(from content: String) async -> [String] {
        guard !content.isEmpty else { return [] }
        
        var entities: [String] = []
        
        // Usa NLTagger para detectar nomes próprios
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = content
        
        // Configura o idioma para português se possível
        if let language = NLLanguageRecognizer.dominantLanguage(for: content) {
            tagger.setLanguage(language, range: content.startIndex..<content.endIndex)
        }
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let range = content.startIndex..<content.endIndex
        
        // Extrai nomes próprios
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
        
        // Se não encontrou entidades com nameType, tenta detectar palavras capitalizadas
        if entities.isEmpty {
            let words = content.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            for word in words {
                let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                // Detecta palavras que começam com maiúscula e têm mais de 2 caracteres
                if trimmed.count > 2,
                   let firstChar = trimmed.first,
                   firstChar.isUppercase,
                   !trimmed.allSatisfy({ $0.isUppercase }), // Não é tudo maiúscula (acrônimo)
                   !entities.contains(trimmed) {
                    entities.append(trimmed)
                }
            }
        }
        
        // Remove duplicatas e limita a 10 entidades
        return Array(Set(entities)).prefix(10).map { $0 }
    }
    
    /// Gera tags a partir de um texto
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de tags sugeridas
    func generateTags(from content: String) async -> [String] {
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
    ///   - instruction: Instrução de como modificar
    /// - Returns: Texto refinado
    func refineText(_ content: String, instruction: String) async -> String {
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

