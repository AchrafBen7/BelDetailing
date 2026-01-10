//
//  VehicleSelectionStepView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct VehicleSelectionStepView: View {
    @Binding var selectedVehicleType: VehicleType?
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Fond sombre
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Bouton retour
                HStack {
                    Button(action: onBack) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Header
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                
                // Liste des véhicules
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(VehicleType.allCases) { vehicleType in
                            VehicleSelectionRow(
                                vehicleType: vehicleType,
                                isSelected: selectedVehicleType == vehicleType
                            ) {
                                selectedVehicleType = vehicleType
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                
                // Bouton continuer
                if selectedVehicleType != nil {
                    Button(action: onContinue) {
                        Text("Continuer")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Icône
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Votre véhicule")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Sélectionnez le type de véhicule")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - Vehicle Selection Row (comme la photo)

private struct VehicleSelectionRow: View {
    let vehicleType: VehicleType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Image du véhicule
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)
                        .frame(width: 80, height: 60)
                    
                    // Image du véhicule depuis Assets
                    if let image = UIImage(named: vehicleType.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(5)
                    } else {
                        // Fallback: icône SF Symbols
                        Image(systemName: vehicleType.icon)
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Texte
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicleType.localizedName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(vehicleType.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Indicateur de sélection
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

