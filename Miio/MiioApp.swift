//
//  MiioApp.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Ponto de entrada principal do aplicativo Miio
@main
struct MiioApp: App {
    /// Store global de entradas
    @StateObject private var store = EntryStore()
    
    /// Indica se deve mostrar a splash screen
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                EntryListView(store: store)
            }
        }
    }
}
