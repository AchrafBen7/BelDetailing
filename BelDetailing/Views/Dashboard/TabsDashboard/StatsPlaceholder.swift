//
//  StatsPlaceholder.swift
//  BelDetailing
//
//  Created by Achraf Benali on 20/11/2025.

import SwiftUI
import RswiftResources

struct StatsPlaceholder: View {

    // Données injectées depuis le ViewModel (pas de mock ici)
    let stats: DetailerStats?
    let popularServices: [PopularServiceUI]

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

                if popularServices.isEmpty {
                    Text(R.string.localizable.detailNoServices())
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                } else {
                    ForEach(popularServices, id: \.name) { service in
                        VStack(alignment: .leading, spacing: 6) {

                            HStack {
                                Text(service.name)
                                    .font(.system(size: 17, weight: .semibold))

                                Spacer()

                                Text(R.string.localizable.statsPriceEuro(Int(service.estimatedEarnings)))
                                    .font(.system(size: 17, weight: .semibold))
                            }

                            Text("\(service.count) réservations")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)

                            Rectangle()
                                .fill(Color.black)
                                .frame(width: barWidth(for: service), height: 5)
                                .cornerRadius(3)
                                .padding(.trailing, 60)
                                .opacity(0.9)

                            Divider()
                        }
                    }
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

                    Text("\(stats?.clientsCount ?? 0)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
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

                    Text(String(format: "%.1f", stats?.rating ?? 0))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
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
    private func barWidth(for service: PopularServiceUI) -> CGFloat {
        let maxCount = max(popularServices.map { $0.count }.max() ?? 1, 1)
        let ratio = CGFloat(service.count) / CGFloat(maxCount)
        return ratio * 220
    }
}

// MARK: - UI Model pour les services populaires (pas de mock, juste un mapping UI)
struct PopularServiceUI: Hashable {
    let name: String
    let estimatedEarnings: Double
    let count: Int
}
