//
//  LocationView.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import SwiftUI

/// View minimalista que exibe informações de localização
struct LocationView: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.accent)
            
            if let address = location.address, !address.isEmpty {
                Text(address)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            } else {
                Text(location.name)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Location View") {
    let location = Location(
        name: "Parque Ibirapuera",
        latitude: -23.5874,
        longitude: -46.6576,
        address: "Av. Pedro Álvares Cabral, São Paulo - SP"
    )
    
    return LocationView(location: location)
        .padding()
}

