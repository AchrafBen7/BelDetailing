//
//  ProvidedCardHorizontal.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI
import RswiftResources

struct ProviderCardHorizontal: View {
  let provider: Detailer

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      // === Image de fond ===
      AsyncImage(url: URL(string: provider.bannerUrl ?? "")) { phase in
        switch phase {
        case .empty:
          Color.gray.opacity(0.15)
        case .success(let image):
          image.resizable().scaledToFill()
        case .failure:
          Color.gray.opacity(0.15)
        @unknown default:
          Color.gray.opacity(0.15)
        }
      }
      .frame(width: 260, height: 200)
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay(
        LinearGradient(
          gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.75)]),
          startPoint: .top,
          endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      )

      // === Contenu ===
      VStack(alignment: .leading, spacing: 4) {
        // Étoiles + note
        HStack(spacing: 6) {
          Image(systemName: "star.fill")
            .font(.system(size: 13))
            .foregroundColor(.white)
          Text(String(format: "%.1f", provider.rating))
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
        .padding(.bottom, 8)

        // Nom du prestataire
        Text(provider.displayName)
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(.white)
          .lineLimit(1)

        // Type de service principal
        if let mainService = provider.serviceCategories.first {
            Text(mainService.localizedTitle)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
        }

        // Durée et distance
        HStack(spacing: 10) {
          Label("2–3h", systemImage: "clock") // tu pourras remplacer par ton vrai champ plus tard
          Label("2.3 km", systemImage: "mappin.and.ellipse") // pareil
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(.white.opacity(0.85))
      }
      .padding(14)
    }
    .frame(width: 260, height: 200)
    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
  }
}

#Preview {
  ProviderCardHorizontal(provider: Detailer.sampleValues.first!)
    .padding()
    .background(Color(R.color.mainBackground.name))
}
