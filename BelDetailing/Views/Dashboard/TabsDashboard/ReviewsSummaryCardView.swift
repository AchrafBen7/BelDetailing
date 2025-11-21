import SwiftUI
import RswiftResources

struct ReviewsSummaryCardView: View {

    let averageRating: Double
    let totalReviews: Int
    let distribution: [Int: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .center, spacing: 20) {

                // --- COLONNE GAUCHE ---
                VStack(alignment: .leading, spacing: 6) {

                    Text(String(format: "%.1f", averageRating))
                        .font(.system(size: 38, weight: .bold))   // ⬅️ Réduit

                    starsRow(for: averageRating)
                        .padding(.top, -4)

                    Text(R.string.localizable.reviewsSummaryCount(totalReviews))
                        .font(.system(size: 14))                  // ⬅️ Réduit
                        .foregroundColor(.gray)
                }

                Spacer()

                // --- COLONNE DROITE ---
                VStack(alignment: .leading, spacing: 8) {
                    ratingBarRow(stars: 5)
                    ratingBarRow(stars: 4)
                    ratingBarRow(stars: 3)
                }
                .frame(maxWidth: 130)                             // ⬅️ Rétréci
            }

        }
        .padding(16)                                             // ⬅️ comme les autres cards
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }

    // MARK: - Stars row
    private func starsRow(for rating: Double) -> some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                let filled = Double(index) <= round(rating)
                Image(systemName: filled ? "star.fill" : "star")
                    .foregroundColor(filled ? .yellow : Color.gray.opacity(0.4))
            }
        }
        .font(.system(size: 15))  // ⬅️ plus fin
    }

    // MARK: - Bar row
    private func ratingBarRow(stars: Int) -> some View {
        let count = distribution[stars] ?? 0
        let maxCount = max(distribution.values.max() ?? 1, 1)
        let ratio = CGFloat(count) / CGFloat(maxCount)

        return HStack(spacing: 6) {

            Text(R.string.localizable.reviewsStarsLine(stars))
                .font(.system(size: 13, weight: .medium))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 5)

                Capsule()
                    .fill(Color.black)
                    .frame(width: 100 * ratio, height: 5)   // ⬅️ plus court
            }

            Text(R.string.localizable.reviewsRowCount(count))
                .font(.system(size: 13))
        }
    }
}
