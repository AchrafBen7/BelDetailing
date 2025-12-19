import SwiftUI
import RswiftResources

struct ProviderCardHorizontal: View {
    let provider: Detailer
    
    var body: some View {
        ZStack(alignment: .topTrailing) {

            // === Image plein cadre ===
            CachedImage(url: provider.bannerURL)
                .frame(width: 260, height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            // === Dégradé doux pour lisibilité ===
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 260, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            // === Badge étoile ORANGE (à droite) ===
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13, weight: .bold))
                Text(String(format: "%.1f", provider.rating))
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(R.color.secondaryOrange))
            .clipShape(Capsule())
            .padding(.top, 10)
            .padding(.trailing, 10)

            // === Contenu bas gauche ===
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let mainService = provider.serviceCategories.first {
                    Text(mainService.localizedTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                HStack(spacing: 10) {
                    // Distance
                    Label(
                        R.string.localizable.detailerDistanceKmValue(provider.mockDistanceKmText),
                        systemImage: "mappin.and.ellipse"
                    )

                    // Petit chip “À domicile”
                    if provider.hasMobileService {
                        domicileChipDark
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(14)
            .frame(width: 260, height: 200, alignment: .bottomLeading)
        }
        .frame(width: 260, height: 200)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }

    // MARK: - Chips

    private var domicileChipDark: some View {
        HStack(spacing: 4) {
            Image(systemName: "car.fill")
                .font(.system(size: 11, weight: .semibold))
            Text(R.string.localizable.detailerAtHome()) // "À domicile"
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.18))
        .clipShape(Capsule())
    }
}

