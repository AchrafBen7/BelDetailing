//
//  ProviderSearchHorizontal.swift
//  BelDetailing
//
//  Created by Achraf Benali on 13/11/2025.
//

import SwiftUI
import RswiftResources

struct ProviderSearchHorizontal: View {
    let provider: Detailer
    
    // Ratio plus rectangulaire (≈ 320x260)
    private let cardSize = CGSize(width: 260, height: 180)
    private let corner: CGFloat = 20
    private var priceText: String {
        let min = provider.minPriceValue // safe: 0 si nil
        if min <= 0 {
            return R.string.localizable.priceOnRequest() // "Sur devis"
        } else {
            return R.string.localizable.priceWithCurrency("\(Int(min))")
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            CachedImage(url: provider.bannerURL, cornerRadius: corner)
                .frame(width: cardSize.width, height: cardSize.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            // Gradient
            LinearGradient(colors: [.clear, .black.opacity(0.75)],
                           startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .frame(width: cardSize.width, height: cardSize.height)
            // Badges en haut
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    badgeRating
                    if provider.hasMobileService { badgeAtHome }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                Spacer()
            }
            .frame(width: cardSize.width, height: cardSize.height)
            // Textes + prix
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.displayName)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(provider.serviceCategories.first?.localizedTitle ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("\(provider.mockDistanceKmText) \(R.string.localizable.distanceKmUnit())")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.95))
                }
                
                Spacer(minLength: 12)
                
                Text(priceText)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
    
    // MARK: - Badges
    private var badgeRating: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill").font(.system(size: 13, weight: .bold))
            Text(String(format: "%.1f", provider.rating))
            Text("(\(provider.reviewCount))")
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(Color.black.opacity(0.55))
        .clipShape(Capsule())
    }
    
    private var badgeAtHome: some View {
        Text(R.string.localizable.badgeAtHome())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(Color(R.color.secondaryOrange))
            .clipShape(Capsule())
    }
}
