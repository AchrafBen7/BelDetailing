//
//  OfferCard.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct OfferCard: View {
  let offer: Offer

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(offer.title)
          "text".textView(style: AppStyle.TextStyle.sectionTitle)
        Spacer()
        Text(String(format: "€ %.0f – %.0f", offer.priceMin, offer.priceMax))
          .font(.system(size: 14, weight: .semibold))
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(Color(R.color.primaryBlue))
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .foregroundStyle(.white)
      }

        offer.city.textView(
            style: AppStyle.TextStyle.description,
            overrideColor: Color.secondary
        )

        HStack(spacing: 6) {
          ForEach([offer.type.rawValue.capitalized, offer.status.rawValue.capitalized], id: \.self) { tag in
            Text(tag)
              .font(.system(size: 11, weight: .medium))
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.gray.opacity(0.12))
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          }
        }

      Divider().padding(.vertical, 4)

      HStack {
          Image(systemName: offer.status == .open ? "bolt.fill" : "pause.circle")
            .foregroundStyle(offer.status == .open ? .green : .gray)

          Text(offer.status.rawValue.capitalized)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(offer.status == .open ? .green : .gray)

        Spacer()
        Text(offer.type.rawValue.capitalized)
          .font(.system(size: 13))
          .foregroundStyle(.secondary)
      }
    }
    .padding(14)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
  }
}

#Preview {
  OfferCard(offer: Offer.sampleValues.first!)
    .padding()
    .background(Color(R.color.mainBackground))
}
