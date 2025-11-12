//
//  ProviderCard.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct ProviderCard: View {
  let provider: Detailer

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .center, spacing: 12) {
        Circle()
          .fill(Color(R.color.secondaryOrange))
          .frame(width: 44, height: 44)
          // ✅ cast en String
          .overlay(Text(String(provider.displayName.prefix(1))).foregroundColor(.white))
          VStack(alignment: .leading, spacing: 2) {
            Text(provider.displayName)
              .textView(style: AppStyle.TextStyle.sectionTitle)

            Text("\(provider.city) • ⭐️ \(String(format: "%.1f", provider.rating)) • \(provider.reviewCount)")
              .textView(style: AppStyle.TextStyle.description, overrideColor: .secondary)
          }


        Spacer()

        Text(String(format: "€ %.0f+", provider.minPrice))
          .font(.system(size: 14, weight: .semibold))
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Color(R.color.primaryBlue))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          .foregroundStyle(.white)
      }

      HStack(spacing: 6) {
        ForEach(provider.serviceCategories.prefix(4), id: \.self) { cat in
          // ✅ utilise le titre localisé (réutilise les clés des filtres)
          Text(cat.localizedTitle)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
      }
    }
    .padding(12)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
  }
}

#Preview {
  ProviderCard(provider: Detailer.sampleValues.first!)
    .padding()
    .background(Color(R.color.mainBackground.name))
}
