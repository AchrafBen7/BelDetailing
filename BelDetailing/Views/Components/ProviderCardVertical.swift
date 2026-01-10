import SwiftUI
import RswiftResources

struct ProviderCardVertical: View {
    let provider: Detailer
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // === Image plein cadre ===
            CachedImage(url: provider.bannerURL)
                .frame(height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // === Dégradé doux pour lisibilité (comme ta maquette) ===
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // === Badge note en haut à droite ===
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", provider.rating))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .padding(10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // === Contenu bas (nom, service, distance, avis) ===
            VStack(alignment: .leading, spacing: 4) {
                // Nom
                Text(provider.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Service principal
                Text(provider.serviceCategories.first?.localizedTitle ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                // Ligne info : distance + avis (PAS d'heures, PAS domicile)
                HStack(spacing: 14) {
                    Label(
                        R.string.localizable.detailerDistanceKmValue(provider.mockDistanceKmText),
                        systemImage: "mappin.and.ellipse"
                    )
                    
                    Spacer()
                    
                    Text("\(provider.reviewCount) \(R.string.localizable.providerReviewsCount())")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(14)
        }
        .frame(height: 200)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}

