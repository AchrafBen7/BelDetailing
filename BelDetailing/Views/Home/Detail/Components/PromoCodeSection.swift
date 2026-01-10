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
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingPromoTitle())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                // --- TEXTFIELD ---
                TextField(
                    R.string.localizable.bookingPromoPlaceholder(),
                    text: $promoCode
                )
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // --- APPLY BUTTON ---
                Button {
                    print("Apply promo: \(promoCode)")
                } label: {
                    Text(R.string.localizable.bookingPromoApply())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .disabled(promoCode.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(promoCode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
}
