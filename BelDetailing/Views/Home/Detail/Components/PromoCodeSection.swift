//
//  PromoCodeSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//

import SwiftUI
import RswiftResources

extension BookingStep3View {
    
    var promoCodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(R.string.localizable.bookingPromoTitle())
                .font(.system(size: 22, weight: .bold))
            
            HStack(spacing: 12) {
                
                // --- TEXTFIELD ---
                TextField(
                    R.string.localizable.bookingPromoPlaceholder(),
                    text: $promoCode
                )
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
                .cornerRadius(16)
                
                // --- APPLY BUTTON ---
                Button {
                    print("Apply promo: \(promoCode)")
                } label: {
                    Text(R.string.localizable.bookingPromoApply())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        .background(Color.black)
                        .cornerRadius(16)
                }
                .disabled(promoCode.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(promoCode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
            .padding(.top, 4)
        }
    }
    
}
