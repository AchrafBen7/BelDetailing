import SwiftUI
import RswiftResources

struct ServiceCardView: View {
    let service: Service

    var body: some View {
        VStack(spacing: 0) {

            // --- IMAGE SERVICE (fait partie de la même card) ---
            ZStack(alignment: .topTrailing) {
                Image(R.image.heroMain.name)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                // --- PRICE BADGE ---
                Text("€\(Int(service.price))")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    .padding(14)
            }

            // --- CONTENT ---
            VStack(alignment: .leading, spacing: 14) {

                // TITLE + DURATION
                HStack {
                    Text(service.name)
                        .font(.system(size: 20, weight: .bold))

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(service.formattedDuration)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.gray)
                }

                // DESCRIPTION
                if let desc = service.description {
                    Text(desc)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }

                // INCLUDED BUBBLE
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text(R.string.localizable.detailIncluded())
                            .font(.system(size: 16, weight: .semibold))
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        Text("• Lavage complet")
                        Text("• Décontamination")
                        Text("• Polissage 2 étapes")
                        Text("• Protection cire")
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)

                // RESERVER BUTTON
                Button {
                    // TODO: open booking
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(R.string.localizable.detailBookService())
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .padding(.top, 6)
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))      // 👈 1 seule card
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.10), lineWidth: 1.1)               // bordure visible
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 5)
        .padding(.horizontal, 8)
    }
}
