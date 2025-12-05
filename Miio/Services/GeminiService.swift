//
//  GeminiService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation

/// Serviço para interagir com a API do Gemini
class GeminiService {
    /// API Key do Gemini
    private let apiKey = "AIzaSyD5JedwQKxB4eDJk5jh07fwUX1YXO0_k_w"
    
    /// URL base da API
    private var baseURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
    }
    
    /// Gera tags usando a API do Gemini
    /// - Parameter content: Conteúdo a ser analisado
    /// - Returns: Array de tags sugeridas
    func generateTags(from content: String) async -> [String] {
        guard !content.isEmpty else { return [] }
        
        let prompt = """
        Analise o seguinte texto e forneça 3 tags curtas e relevantes que descrevem os principais tópicos.
        Retorne apenas as tags separadas por vírgula, sem explicações adicionais.
        Use apenas palavras em português.
        
        Texto: \(content)
        """
        
        do {
            let requestBody: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ]
            
            guard let url = URL(string: baseURL) else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return []
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                
                // Extrai tags do texto retornado
                let tags = text.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && $0.count > 2 }
                    .map { $0.lowercased() }
                
                return Array(tags.prefix(3))
            }
        } catch {
            // Erro na chamada da API do Gemini é tratado silenciosamente
        }
        
        return []
    }
}

