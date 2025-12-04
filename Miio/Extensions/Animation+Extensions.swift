//
//  Animation+Extensions.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Extensões para animações sutis e discretas
extension Animation {
    /// Animação sutil para feedback de interação
    /// - Returns: Animação de spring suave
    static var subtleSpring: Animation {
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
    }
    
    /// Animação discreta para mudanças de estado
    /// - Returns: Animação ease in/out rápida
    static var discrete: Animation {
        .easeInOut(duration: 0.2)
    }
    
    /// Animação para navegação
    /// - Returns: Animação de transição suave
    static var navigation: Animation {
        .spring(response: 0.35, dampingFraction: 0.85)
    }
    
    /// Animação para aparecimento de elementos
    /// - Returns: Animação de fade com spring
    static var appear: Animation {
        .spring(response: 0.4, dampingFraction: 0.75)
        .combined(with: .opacity)
    }
    
    /// Animação para desaparecimento de elementos
    /// - Returns: Animação de fade rápida
    static var disappear: Animation {
        .easeOut(duration: 0.15)
        .combined(with: .opacity)
    }
}

/// Modificadores de animação para views
extension View {
    /// Aplica animação sutil quando um valor muda
    /// - Parameters:
    ///   - value: Valor que dispara a animação
    ///   - animation: Tipo de animação (padrão: subtleSpring)
    /// - Returns: View com animação aplicada
    func animateOnChange<T: Equatable>(
        of value: T,
        animation: Animation = .subtleSpring
    ) -> some View {
        self.animation(animation, value: value)
    }
    
    /// Aplica animação de aparecimento
    /// - Parameter isVisible: Se a view está visível
    /// - Returns: View com animação de aparecimento
    func animateAppearance(_ isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95)
            .animation(.appear, value: isVisible)
    }
    
    /// Aplica animação de hover (para interações)
    /// - Parameter isHovered: Se está sendo hovered
    /// - Returns: View com animação de hover
    func animateHover(_ isHovered: Bool) -> some View {
        self
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.subtleSpring, value: isHovered)
    }
}

/// View modifier para animação de lista
struct ListAnimationModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.appear.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Aplica animação de entrada em lista
    /// - Parameter delay: Delay da animação
    /// - Returns: View com animação aplicada
    func listAnimation(delay: Double = 0) -> some View {
        modifier(ListAnimationModifier(delay: delay))
    }
}

