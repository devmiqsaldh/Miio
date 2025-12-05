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
            DesignSystem.Colors.splashBackground
                .ignoresSafeArea()
            
            Text("Miio")
                .font(DesignSystem.Typography.largeTitle())
                .foregroundColor(.white)
        }
    }
}

