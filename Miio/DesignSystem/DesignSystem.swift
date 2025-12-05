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
        static let primary = Color("PrimaryColor")
        
        /// Cor secundária
        static let secondary = Color("SecondaryColor")
        
        /// Cor de fundo principal (marrom muito claro)
        static let background = Color("BackgroundColor")
        
        /// Cor de fundo secundária (marrom claro)
        static let secondaryBackground = Color("SecondaryBackgroundColor")
        
        /// Cor de texto primária
        static let textPrimary = Color("TextPrimaryColor")
        
        /// Cor de texto secundária
        static let textSecondary = Color("TextSecondaryColor")
        
        /// Cor de destaque
        static let accent = Color("AccentColor")
        
        /// Cor de fundo do splash screen (marrom mais carregado)
        static let splashBackground = Color("SplashBackgroundColor")
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
            .shadow(color: DesignSystem.Colors.textPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
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

