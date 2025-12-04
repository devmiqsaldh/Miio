//
//  ViewBuilder+Extensions.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Extensões para ViewBuilder facilitando a construção de interfaces
extension ViewBuilder {
    /// Cria uma view condicional baseada em uma condição
    /// - Parameters:
    ///   - condition: Condição booleana
    ///   - trueContent: Conteúdo quando verdadeiro
    ///   - falseContent: Conteúdo quando falso
    /// - Returns: View apropriada baseada na condição
    @ViewBuilder
    static func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder then trueContent: () -> TrueContent,
        @ViewBuilder else falseContent: () -> FalseContent
    ) -> some View {
        if condition {
            trueContent()
        } else {
            falseContent()
        }
    }
    
    /// Cria uma view condicional que pode ser nil
    /// - Parameters:
    ///   - condition: Condição booleana
    ///   - content: Conteúdo quando verdadeiro
    /// - Returns: View ou EmptyView
    @ViewBuilder
    static func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder then content: () -> Content
    ) -> some View {
        if condition {
            content()
        }
    }
}

/// Extensões úteis para View
extension View {
    /// Aplica animação sutil e discreta
    /// - Parameter value: Valor que dispara a animação
    /// - Returns: View com animação aplicada
    func subtleAnimation<T: Equatable>(value: T) -> some View {
        self.animation(.easeInOut(duration: 0.2), value: value)
    }
    
    /// Aplica animação de fade
    /// - Parameter opacity: Opacidade desejada
    /// - Returns: View com fade aplicado
    func fadeAnimation(opacity: Double) -> some View {
        self.opacity(opacity)
            .animation(.easeInOut(duration: 0.15), value: opacity)
    }
    
    /// Aplica animação de escala sutil
    /// - Parameter scale: Escala desejada
    /// - Returns: View com escala aplicada
    func scaleAnimation(scale: CGFloat) -> some View {
        self.scaleEffect(scale)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scale)
    }
}

/// Helper para construir listas de forma mais limpa
struct ConditionalList<Content: View>: View {
    let condition: Bool
    let content: () -> Content
    
    init(_ condition: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.condition = condition
        self.content = content
    }
    
    var body: some View {
        if condition {
            content()
        }
    }
}

