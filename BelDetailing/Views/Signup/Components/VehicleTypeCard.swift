//
//  VehicleTypeCard.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct VehicleTypeCard: View {
    let vehicleType: VehicleType
    let isSelected: Bool
    let isDarkStyle: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Image du véhicule
                ZStack {
                    // Fond blanc pour l'image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 100)
                    
                    // Image du véhicule (ou placeholder si pas d'image)
                    if let image = UIImage(named: vehicleType.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .padding(10)
                    } else {
                        // Fallback: icône SF Symbols
                        Image(systemName: vehicleType.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.black : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                
                // Nom du véhicule
                Text(vehicleType.localizedName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDarkStyle ? .white : .black)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(vehicleType.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .background(isDarkStyle ? Color.white.opacity(0.1) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? .black.opacity(0.1) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

