//  ExtensionServiceCardStep2.swift
//  BelDetailing

import SwiftUI
import RswiftResources

extension BookingStep2View {
    
    var serviceSummaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // === IMAGE FLUSH AVEC LE BORD DU GROS CARD ===
            AsyncImage(url: service.serviceImageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    Color.gray.opacity(0.15)
                case .failure:
                    Image(systemName: "car.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                @unknown default:
                    Color.gray.opacity(0.15)
                }
            }
            .frame(height: 180)
            .clipped()
            // ⬇️ on annule le padding(24) de la big card
            .padding(.horizontal, -24)
            .padding(.top, -24)

            // === CONTENU TEXTE ===
            VStack(alignment: .leading, spacing: 10) {

                Text(service.name)
                    .font(.system(size: 20, weight: .bold))

                HStack(spacing: 12) {
                    Text("€\(Int(service.price))")
                        .font(.system(size: 17, weight: .semibold))

                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(service.formattedDuration)
                    }
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                }

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", detailer.rating))
                        .font(.system(size: 15, weight: .semibold))
                    Text("(\(detailer.reviewCount))")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))

                    Spacer()

                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(detailer.city)
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 16)   // petit espace sous l’image
        }
    }
}
