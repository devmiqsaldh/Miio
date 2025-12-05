//
//  MiioApp.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI
import WidgetKit

/// Ponto de entrada principal do aplicativo Miio
@main
struct MiioApp: App {
    /// Store global de entradas
    @StateObject private var store = EntryStore()
    
    var body: some Scene {
        WindowGroup {
            EntryListView(store: store)
        }
    }
}

/// Bundle do widget
@main
struct MiioWidgetBundle: WidgetBundle {
    var body: some Widget {
        MiioWidget()
    }
}
