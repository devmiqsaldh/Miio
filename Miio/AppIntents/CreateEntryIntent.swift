//
//  CreateEntryIntent.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import AppIntents
import Foundation

/// Intent para criar uma nova entrada do diário via Siri ou Shortcuts
struct CreateEntryIntent: AppIntent {
    /// Título da intent
    static var title: LocalizedStringResource = "Criar Entrada no Diário"
    
    /// Descrição da intent
    static var description = IntentDescription("Cria uma nova entrada no seu diário Miio")
    
    /// Parâmetros da intent
    @Parameter(title: "Título")
    var title: String
    
    @Parameter(title: "Conteúdo")
    var content: String
    
    /// Executa a intent
    /// - Returns: Resultado da execução
    func perform() async throws -> some IntentResult {
        return await MainActor.run {
            let store = EntryStore()
            let entry = Entry(
                title: title,
                content: content
            )
            store.addEntry(entry)
            return .result()
        }
    }
}

/// Intent para buscar entradas no diário
struct SearchEntriesIntent: AppIntent {
    static var title: LocalizedStringResource = "Buscar no Diário"
    static var description = IntentDescription("Busca entradas no seu diário Miio")
    
    @Parameter(title: "Termo de busca")
    var searchText: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return await MainActor.run {
            let store = EntryStore()
            let results = store.searchEntries(searchText)
            
            return .result(
                value: results.map { $0.title },
                view: SearchResultsView(entries: results)
            )
        }
    }
}

/// View que exibe resultados da busca
struct SearchResultsView: View {
    let entries: [Entry]
    
    var body: some View {
        List(entries) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                Text(entry.content)
                    .font(.caption)
                    .lineLimit(2)
            }
        }
    }
}

/// Intent para obter a última entrada do diário
struct GetLastEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Última Entrada do Diário"
    static var description = IntentDescription("Retorna a última entrada criada no diário")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await MainActor.run {
            let store = EntryStore()
            guard let lastEntry = store.entries.first else {
                return .result(dialog: "Você ainda não tem entradas no diário")
            }
            
            let dateString = lastEntry.createdAt.formattedForDiary()
            return .result(dialog: "Sua última entrada é '\(lastEntry.title)', criada em \(dateString)")
        }
    }
}

