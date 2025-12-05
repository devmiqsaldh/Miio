//
//  SplashView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// Tela de splash do aplicativo
struct SplashView: View {
    var body: some View {
        ZStack {
            DesignSystem.Colors.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Miio")
                    .font(DesignSystem.Typography.largeTitle())
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SplashView()
}

