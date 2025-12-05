//
//  MiioWidget.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

// IMPORTANTE: Widgets precisam de um target separado (Widget Extension) no Xcode
// Este arquivo está comentado para evitar erros de compilação
// Para usar widgets:
// 1. Crie um Widget Extension target no Xcode
// 2. Mova este arquivo para o target do widget
// 3. Configure App Groups para compartilhar dados entre app e widget

/*
import WidgetKit
import SwiftUI

/// Widget que exibe a última entrada do diário
struct MiioWidget: Widget {
    /// Identificador do widget
    let kind: String = "MiioWidget"
    
    /// Configuração do widget
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MiioTimelineProvider()) { entry in
            MiioWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Meu Diário")
        .description("Veja sua última entrada do diário")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Provider de timeline para o widget
struct MiioTimelineProvider: TimelineProvider {
    /// Placeholder para preview
    func placeholder(in context: Context) -> MiioWidgetEntry {
        MiioWidgetEntry(
            date: Date(),
            entry: Entry(
                title: "Minha Entrada",
                content: "Esta é uma entrada de exemplo do diário..."
            )
        )
    }
    
    /// Snapshot para preview
    func getSnapshot(in context: Context, completion: @escaping (MiioWidgetEntry) -> Void) {
        let store = EntryStore()
        let lastEntry = store.entries.first ?? Entry(
            title: "Nenhuma entrada",
            content: "Crie sua primeira entrada no diário"
        )
        
        let entry = MiioWidgetEntry(date: Date(), entry: lastEntry)
        completion(entry)
    }
    
    /// Timeline com atualizações
    func getTimeline(in context: Context, completion: @escaping (Timeline<MiioWidgetEntry>) -> Void) {
        let store = EntryStore()
        let lastEntry = store.entries.first ?? Entry(
            title: "Nenhuma entrada",
            content: "Crie sua primeira entrada no diário"
        )
        
        let entry = MiioWidgetEntry(date: Date(), entry: lastEntry)
        
        // Atualiza a cada hora
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

/// Entrada do widget
struct MiioWidgetEntry: TimelineEntry {
    /// Data da entrada
    let date: Date
    
    /// Entrada do diário (modelo do app)
    let entry: Entry
}

/// View do widget
struct MiioWidgetEntryView: View {
    /// Entrada do widget (use explicitamente MiioWidgetEntry para evitar colisão de nomes)
    var entry: MiioWidgetEntry
    
    /// Ambiente do widget
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry.entry)
        case .systemMedium:
            MediumWidgetView(entry: entry.entry)
        default:
            SmallWidgetView(entry: entry.entry)
        }
    }
}

/// View pequena do widget
struct SmallWidgetView: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.orange)
                Text("Miio")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(entry.title.isEmpty ? "Sem título" : entry.title)
                .font(.headline)
                .lineLimit(2)
            
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(entry.createdAt.formattedForDiary())
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// View média do widget
struct MediumWidgetView: View {
    let entry: Entry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(.orange)
                    Text("Miio - Meu Diário")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Text(entry.title.isEmpty ? "Sem título" : entry.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.subheadline)
                        .lineLimit(4)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    if let location = entry.location {
                        Label(location.name, systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(entry.createdAt.formattedForDiary())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    MiioWidget()
} timeline: {
    MiioWidgetEntry(
        date: Date(),
        entry: Entry(
            title: "Dia Incrível",
            content: "Hoje foi um dia maravilhoso! Passei a tarde na praia..."
        )
    )
}

#Preview(as: .systemMedium) {
    MiioWidget()
} timeline: {
    MiioWidgetEntry(
        date: Date(),
        entry: Entry(
            title: "Dia Incrível",
            content: "Hoje foi um dia maravilhoso! Passei a tarde na praia com amigos..."
        )
    )
}
*/
