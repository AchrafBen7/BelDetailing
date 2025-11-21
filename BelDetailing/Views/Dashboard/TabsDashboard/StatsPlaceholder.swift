//
//  StatsPlaceholder.swift
//  BelDetailing
//
//  Created by Achraf Benali on 20/11/2025.


import SwiftUI
import RswiftResources

struct StatsPlaceholder: View {

    // Mock data
    private let stats = DetailerStats.sample

    private let popularServices: [(name: String, earnings: Int, count: Int)] = [
        ("Detailing Complet", 1800, 12),
        ("Polissage Carrosserie", 680, 8),
        ("Nettoyage Intérieur", 260, 4)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {

            // TITLE
            Text(R.string.localizable.statsTitle())
                .font(.system(size: 26, weight: .bold))
                .padding(.horizontal, 20)

            // POPULAR SERVICES CARD
            VStack(alignment: .leading, spacing: 20) {

                Text(R.string.localizable.statsPopularServices())
                    .font(.system(size: 18, weight: .semibold))

                ForEach(popularServices, id: \.name) { service in
                    VStack(alignment: .leading, spacing: 6) {

                        HStack {
                            Text(service.name)
                                .font(.system(size: 17, weight: .semibold))

                            Spacer()

                            Text(R.string.localizable.statsPriceEuro(service.earnings))
                                .font(.system(size: 17, weight: .semibold))
                        }

                        // Replaced missing localization key with manual formatted text
                        Text("\(service.count) réservations")
                            .foregroundColor(.gray)

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: barWidth(for: service), height: 5)
                            .cornerRadius(3)
                            .padding(.trailing, 60)
                            .opacity(0.9)
                    }

                    Divider()
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
            .padding(.horizontal, 20)

            // METRICS BLOCKS
            HStack(spacing: 16) {

                // NEW CLIENTS
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "person.3")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)

                    Text(R.string.localizable.statsNewClients())
                        .font(.system(size: 15, weight: .medium))

                    Text("+\(stats.totalBookings - stats.completedBookings)")
                        .font(.system(size: 26, weight: .bold))

                    Text(R.string.localizable.statsNewClientsVariation(16))
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)

                // SATISFACTION
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "star")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)

                    Text(R.string.localizable.statsSatisfaction())
                        .font(.system(size: 15, weight: .medium))

                    Text(String(format: "%.1f/5", stats.ratingAverage))
                        .font(.system(size: 26, weight: .bold))

                    Text(R.string.localizable.statsReviewsCount(stats.totalReviews))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Helpers
    private func barWidth(for service: (name: String, earnings: Int, count: Int)) -> CGFloat {
        let max = popularServices.first?.earnings ?? 1
        return CGFloat(service.earnings) / CGFloat(max) * 220
    }
}
