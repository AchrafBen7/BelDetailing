import SwiftUI
import RswiftResources

struct OfferMarketplaceCardView: View {

    let offer: Offer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // TITLE + BADGE
            HStack(alignment: .top) {
                Text(offer.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    OfferTypeBadge(type: offer.type)
                }
            }

            // COMPANY
            if let companyName = offer.companyName {
                Text(companyName)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            // META LINE
            HStack(spacing: 16) {
                Label(offer.city, systemImage: "location")
                Label("\(offer.vehicleCount) véhicules", systemImage: "car")
                if let count = offer.applicationsCount {
                    Label("\(count) candidats", systemImage: "person.2")
                }
            }
            .font(.system(size: 13))
            .foregroundColor(.gray)

            Divider()

            // PRICE + DATE
            HStack {
                Text(offer.formattedBudget) // basé sur priceMin/priceMax
                    .font(.system(size: 22, weight: .bold))

                Spacer()

                // Si tu veux une relativeDate, ajoute-la au modèle plus tard
                // Ici, on ne l’a pas, donc on laisse vide ou on commente.
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct OfferTypeBadge: View {
    let type: OfferType

    var body: some View {
        Text(type.localizedTitle)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(type == .recurring ? Color.orange : Color.orange)
            .clipShape(Capsule())
    }
}

// Petit helper pour l’affichage du budget
private extension Offer {
    var formattedBudget: String {
        if priceMin <= 0, priceMax > 0 {
            return "€\(Int(priceMax))"
        } else if priceMin > 0, priceMax > 0, priceMin != priceMax {
            return "€\(Int(priceMin)) – €\(Int(priceMax))"
        } else {
            return "€\(Int(priceMin))"
        }
    }
}
