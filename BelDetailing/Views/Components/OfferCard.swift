//  OfferCard.swift
//  BelDetailing
//
//  Created by Achraf Benali on 13/11/2025.
//

import SwiftUI
import RswiftResources

struct OfferCard: View {
    let offer: Offer

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // 🔹 Titre
            Text(offer.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            // 🔹 Catégorie + type
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.category.localizedTitle)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                Text(offer.type.localizedTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
            }

            // 🔹 Infos (ligne type Indeed)
            HStack(spacing: 14) {
                Label("\(offer.vehicleCount)", systemImage: "car.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Label("€\(Int(offer.priceMin))–\(Int(offer.priceMax))", systemImage: "eurosign.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Label(offer.city, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            // 🔹 Nombre de candidatures
            if let count = offer.applicationsCount, count > 0 {
                Label("\(count) \(R.string.localizable.offerApplicationsLabel())",
                      systemImage: "person.2")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            // 🔹 Boutons: Détails + Postuler
            HStack(spacing: 8) {
                Button {
                    print("Details tapped")
                } label: {
                    Text(R.string.localizable.offerButtonDetails())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.25), lineWidth: 1)
                        )
                }

                Button {
                    print("Apply tapped")
                } label: {
                    Text(R.string.localizable.offerButtonApply())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        // ⬇️ Ombre un peu plus forte qu’avant
        .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
        .overlay(alignment: .topTrailing) {
            Text(offer.status.localizedTitle)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(offer.status.badgeBackground)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(10)
        }
    }
}
