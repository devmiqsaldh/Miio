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
        // Nota: Em produção, isso usaria o framework Foundation Models da Apple
        // Por enquanto, retorna um resumo simples baseado em heurísticas
        
        guard content.count > 100 else { return nil }
        
        let sentences = content.components(separatedBy: ". ")
        guard sentences.count > 2 else { return nil }
        
        // Retorna as primeiras 2-3 frases como resumo
        let summarySentences = Array(sentences.prefix(3))
        return summarySentences.joined(separator: ". ") + "."
    }
    
    /// Extrai entidades (pessoas, lugares) de um texto usando NSLinguisticTagger
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de entidades encontradas
    func extractEntities(from content: String) async -> [String] {
        var entities: [String] = []
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = content
        
        let range = content.startIndex..<content.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                switch tag {
                case .personalName, .placeName, .organizationName:
                    let entity = String(content[tokenRange])
                    if !entities.contains(entity) && entity.count > 2 {
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
    
    /// Entende o texto respondendo perguntas sobre ele
    /// - Parameters:
    ///   - content: Conteúdo a ser analisado
    ///   - question: Pergunta sobre o conteúdo
    /// - Returns: Resposta baseada no conteúdo
    func understandText(_ content: String, question: String) async -> String {
        // Em produção, usaria Foundation Models para compreensão profunda
        // Por enquanto, retorna análise básica baseada em palavras-chave
        
        let lowerContent = content.lowercased()
        let lowerQuestion = question.lowercased()
        
        if lowerQuestion.contains("o que acontece") || lowerQuestion.contains("o que") {
            let sentences = content.components(separatedBy: ". ")
            if let firstSentence = sentences.first, firstSentence.count > 20 {
                return firstSentence + "."
            }
        }
        
        if lowerQuestion.contains("quem") {
            let entities = await extractEntities(from: content)
            if let firstEntity = entities.first {
                return "A pessoa mencionada é: \(firstEntity)"
            }
        }
        
        if lowerQuestion.contains("onde") {
            let sentences = content.components(separatedBy: ". ")
            for sentence in sentences {
                if sentence.lowercased().contains("em ") || sentence.lowercased().contains("na ") || sentence.lowercased().contains("no ") {
                    return sentence.trimmingCharacters(in: .whitespaces) + "."
                }
            }
        }
        
        return "Com base no texto, a resposta está relacionada ao conteúdo mencionado."
    }
    
    /// Compõe escrita criativa baseada em um prompt
    /// - Parameter prompt: Prompt criativo (ex: "Gere uma pequena história de ninar sobre uma raposa")
    /// - Returns: Texto criativo gerado
    func composeCreativeWriting(prompt: String) async -> String {
        // Em produção, usaria Foundation Models para geração criativa
        // Por enquanto, retorna texto de exemplo baseado no prompt
        
        let lowerPrompt = prompt.lowercased()
        
        if lowerPrompt.contains("história") && lowerPrompt.contains("raposa") {
            return """
            Era uma vez uma raposa muito esperta que vivia em uma floresta encantada. 
            Todas as noites, ela contava histórias para os outros animais antes de dormirem. 
            Sua voz suave acalmava todos, e os animais adormeciam felizes, sonhando com aventuras mágicas.
            """
        }
        
        if lowerPrompt.contains("história") && lowerPrompt.contains("ninar") {
            return """
            Em um reino distante, havia um contador de histórias que todas as noites visitava 
            as crianças para contar contos mágicos. Seus contos eram tão encantadores que 
            as crianças adormeciam rapidamente, sonhando com mundos fantásticos.
            """
        }
        
        return "Esta é uma história criativa baseada no seu prompt: \(prompt)"
    }
    
    /// Gera diálogo com uma voz específica
    /// - Parameters:
    ///   - prompt: Prompt do diálogo (ex: "Responda com a voz de um taberneiro amigável")
    ///   - context: Contexto adicional
    /// - Returns: Diálogo gerado
    func generateDialogue(prompt: String, context: String? = nil) async -> String {
        // Em produção, usaria Foundation Models para geração de diálogo
        // Por enquanto, retorna diálogo de exemplo
        
        let lowerPrompt = prompt.lowercased()
        
        if lowerPrompt.contains("taberneiro") || lowerPrompt.contains("amigável") {
            return """
            "Bem-vindo, viajante! Entre, entre! Temos a melhor cerveja da região. 
            Sente-se, conte-me sobre suas aventuras. Estou sempre disposto a ouvir 
            uma boa história enquanto você descansa os pés."
            """
        }
        
        if lowerPrompt.contains("sábio") || lowerPrompt.contains("ancião") {
            return """
            "Ah, jovem aprendiz, você busca conhecimento. A sabedoria vem com o tempo, 
            mas posso compartilhar o que aprendi em minhas longas jornadas. 
            Escute com atenção, pois cada palavra carrega um ensinamento."
            """
        }
        
        return "Diálogo gerado baseado no prompt: \(prompt)"
    }
}

