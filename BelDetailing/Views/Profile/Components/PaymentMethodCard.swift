//
//  PaymentMethodCard.swift
//  BelDetailing
//
//  Created by Achraf Benali on 22/12/2025.
//
import SwiftUI

struct PaymentMethodCard: View {
    let method: AppPaymentMethod

    var body: some View {
        HStack(spacing: 16) {

            // Icône marque: si asset introuvable, fallback SF Symbol
            if let uiImage = UIImage(named: method.iconName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 26)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "creditcard")
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(method.displayName)
                    .font(.system(size: 16, weight: .semibold))

                Text("Expire \(method.expiryFormatted)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            if method.isDefault {
                Text("Par défaut")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}
