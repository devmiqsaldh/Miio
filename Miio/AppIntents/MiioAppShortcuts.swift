//
//  MiioAppShortcuts.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import AppIntents

/// Configuração de atalhos do aplicativo para Siri e Shortcuts
struct MiioAppShortcuts: AppShortcutsProvider {
    /// Atalhos disponíveis
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateEntryIntent(),
            phrases: [
                "Criar entrada no \(.applicationName)",
                "Adicionar ao diário \(.applicationName)",
                "Anotar no \(.applicationName)"
            ],
            shortTitle: "Criar Entrada",
            systemImageName: "book.fill"
        )
        
        AppShortcut(
            intent: SearchEntriesIntent(),
            phrases: [
                "Buscar no \(.applicationName)",
                "Procurar no diário \(.applicationName)"
            ],
            shortTitle: "Buscar Entradas",
            systemImageName: "magnifyingglass"
        )
        
        AppShortcut(
            intent: GetLastEntryIntent(),
            phrases: [
                "Última entrada no \(.applicationName)",
                "Quando foi minha última entrada no \(.applicationName)"
            ],
            shortTitle: "Última Entrada",
            systemImageName: "clock.fill"
        )
    }
    
    /// Ícone do aplicativo para atalhos
    static var shortcutTileColor: ShortcutTileColor {
        .orange
    }
}

