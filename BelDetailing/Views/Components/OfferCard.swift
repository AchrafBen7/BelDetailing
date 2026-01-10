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
        VStack(alignment: .leading, spacing: 16) {
            // Header avec titre et badge de statut
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    // Titre
                    Text(offer.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    // Type badge
                    Text(offer.type.localizedTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Badge de statut
                Text(offer.status.localizedTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(offer.status.badgeBackground)
                    .clipShape(Capsule())
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Informations principales
            VStack(alignment: .leading, spacing: 12) {
                // Budget
                HStack(spacing: 8) {
                    Image(systemName: "eurosign.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                    Text("€\(Int(offer.priceMin)) – €\(Int(offer.priceMax))")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                // Localisation
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                    Text("\(offer.city) • \(offer.postalCode)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Nombre de véhicules
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                    Text(offer.vehicleCount == 1 ? "\(offer.vehicleCount) véhicule" : "\(offer.vehicleCount) véhicules")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Nombre de candidatures (si disponible)
                if let count = offer.applicationsCount, count > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.7))
                        Text("\(count) \(R.string.localizable.offerApplicationsLabel())")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Catégorie
            Text(offer.category.localizedTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}
