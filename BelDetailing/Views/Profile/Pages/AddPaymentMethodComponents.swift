//
//  AddPaymentMethodComponents.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Composants extraits de AddPaymentMethodView pour respecter la limite de longueur
//

import SwiftUI
import UIKit
import StripePaymentSheet
import RswiftResources

// MARK: - Card Visual Representation Component

struct CardVisualRepresentation: View {
    let cardBrand: String
    let last4Digits: String
    let expirationDate: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text(cardBrand)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Spacer()
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    Text(last4Digits)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VALID THRU")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(expirationDate.isEmpty ? "08/26" : expirationDate)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CVV")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        HStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}



