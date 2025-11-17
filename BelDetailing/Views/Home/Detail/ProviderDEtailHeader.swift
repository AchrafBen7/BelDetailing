//
//  ProviderDEtailHeader.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import RswiftResources

struct DetailerDetailHeaderView: View {
    let detailer: Detailer

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // --- BANNER IMAGE ---
            AsyncImage(url: detailer.bannerURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.black.opacity(0.2)
            }
            .frame(height: 260)
            .clipped()
            .overlay(Color.black.opacity(0.35))      // assombrit légèrement
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color.black.opacity(0.45), Color.clear],
                    startPoint: .top, endPoint: .center
                )
            }

            // --- TEXTES ---
            VStack(alignment: .leading, spacing: 8) {

                Text(detailer.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", detailer.rating))
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))

                    Text("(\(detailer.reviewCount) avis)")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 16))
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.85))
                    Text("\(detailer.city), \(detailer.postalCode)")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 16))
                }

                if detailer.hasMobileService {
                    Text(R.string.localizable.detailMobileService())
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }

            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
    }
}
