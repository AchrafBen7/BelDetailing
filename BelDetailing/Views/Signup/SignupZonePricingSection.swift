//
//  SignupZonePricingSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupZonePricingSection: View {
    @Binding var providerBaseCity: String
    @Binding var providerPostalCode: String
    @Binding var providerMinPrice: Double
    @Binding var providerHasMobileService: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Zone & Tarifs")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 20) {
                // Ville et Code postal
                HStack(spacing: 16) {
                    BDInputField(
                        title: "Ville",
                        placeholder: "Ville",
                        text: $providerBaseCity,
                        keyboard: .default,
                        isSecure: false,
                        icon: "mappin.circle",
                        showError: providerBaseCity.trimmingCharacters(in: .whitespaces).isEmpty && !providerBaseCity.isEmpty,
                        errorText: "Ville requise",
                        isDarkStyle: true
                    )
                    
                    BDInputField(
                        title: "Code postal",
                        placeholder: "Code postal",
                        text: $providerPostalCode,
                        keyboard: .numberPad,
                        isSecure: false,
                        icon: "number",
                        showError: providerPostalCode.trimmingCharacters(in: .whitespaces).isEmpty && !providerPostalCode.isEmpty,
                        errorText: "Code postal requis",
                        isDarkStyle: true
                    )
                }
                
                // Prix minimum
                VStack(alignment: .leading, spacing: 10) {
                    Text("Prix minimum")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 12) {
                        Button {
                            if providerMinPrice > 0 {
                                providerMinPrice -= 5
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("€ \(Int(providerMinPrice))")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(minWidth: 80)
                        
                        Button {
                            providerMinPrice += 5
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                    )
                }
                
                // Service mobile
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 24)
                        Text("Service mobile")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Toggle("", isOn: $providerHasMobileService)
                            .tint(.orange)
                    }
                    
                    Text("Je me déplace chez le client")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.65))
                        .padding(.leading, 34)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

