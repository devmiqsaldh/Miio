//
//  DesignSystem.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Sistema de design do aplicativo Miio
enum DesignSystem {
    /// Cores do sistema de design
    enum Colors {
        /// Cor primária do aplicativo (marrom claro)
        static let primary = Color(red: 0.75, green: 0.60, blue: 0.50)
        
        /// Cor secundária
        static let secondary = Color(red: 0.65, green: 0.50, blue: 0.40)
        
        /// Cor de fundo principal
        static let background = Color(.systemBackground)
        
        /// Cor de fundo secundária
        static let secondaryBackground = Color(.secondarySystemBackground)
        
        /// Cor de texto primária
        static let textPrimary = Color(.label)
        
        /// Cor de texto secundária
        static let textSecondary = Color(.secondaryLabel)
        
        /// Cor de destaque
        static let accent = Color(red: 0.70, green: 0.55, blue: 0.45)
    }
    
    /// Espaçamentos padronizados
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    /// Raio de borda padronizado
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    /// Tipografia
    enum Typography {
        /// Título grande
        static func largeTitle() -> Font {
            .system(size: 34, weight: .bold, design: .default)
        }
        
        /// Título
        static func title() -> Font {
            .system(size: 28, weight: .bold, design: .default)
        }
        
        /// Título 2
        static func title2() -> Font {
            .system(size: 22, weight: .semibold, design: .default)
        }
        
        /// Título 3
        static func title3() -> Font {
            .system(size: 20, weight: .semibold, design: .default)
        }
        
        /// Corpo
        static func body() -> Font {
            .system(size: 17, weight: .regular, design: .default)
        }
        
        /// Corpo em negrito
        static func bodyBold() -> Font {
            .system(size: 17, weight: .semibold, design: .default)
        }
        
        /// Caption
        static func caption() -> Font {
            .system(size: 12, weight: .regular, design: .default)
        }
    }
}

/// Modificadores de estilo reutilizáveis
extension View {
    /// Aplica estilo de card padrão
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Aplica estilo de botão primário
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.bodyBold())
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    /// Aplica estilo de botão secundário
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.body())
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

