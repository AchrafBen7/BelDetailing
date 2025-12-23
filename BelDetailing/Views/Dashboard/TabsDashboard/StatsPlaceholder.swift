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

            // KPI CARD (earnings + variation)
            if let stats {
                earningsCard(stats)
                    .padding(.horizontal, 20)
            } else {
                placeholderCard(title: R.string.localizable.dashboardEarningsThisMonth())
                    .padding(.horizontal, 20)
            }

            // KPI GRID (reservations, rating, clients)
            HStack(spacing: 16) {
                metricCard(
                    icon: "calendar",
                    title: R.string.localizable.dashboardStatReservations(),
                    value: "\(stats?.reservationsCount ?? 0)"
                )
                metricCard(
                    icon: "star.fill",
                    title: R.string.localizable.dashboardStatRating(),
                    value: String(format: "%.1f", Double(stats?.rating ?? 0))
                )
                metricCard(
                    icon: "person.2",
                    title: R.string.localizable.dashboardStatClients(),
                    value: "\(stats?.clientsCount ?? 0)"
                )
            }
            .padding(.horizontal, 20)

            // POPULAR SERVICES CARD (inchangé)
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

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Earnings Card
    private func earningsCard(_ stats: DetailerStats) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(R.string.localizable.dashboardEarningsThisMonth())
                .font(.system(size: 15))
                .foregroundColor(.gray)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("€\(Int(stats.monthlyEarnings))")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.black)

                HStack(spacing: 6) {
                    Image(systemName: stats.variationPercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(stats.variationPercent >= 0 ? "+" : "")\(Int(stats.variationPercent))%")
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((stats.variationPercent >= 0 ? Color.green : Color.red).opacity(0.12))
                .foregroundColor(stats.variationPercent >= 0 ? .green : .red)
                .clipShape(Capsule())
            }

            Text(R.string.localizable.dashboardVsLastMonth())
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }

    // MARK: - Metric Card
    private func metricCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.gray)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }

    // MARK: - Helpers
    private func barWidth(for service: PopularServiceUI) -> CGFloat {
        let maxCount = max(popularServices.map { $0.count }.max() ?? 1, 1)
        let ratio = CGFloat(service.count) / CGFloat(maxCount)
        return ratio * 220
    }

    private func placeholderCard(title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 28)
                .cornerRadius(6)
                .redacted(reason: .placeholder)
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 18)
                .cornerRadius(6)
                .redacted(reason: .placeholder)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }
}

// MARK: - UI Model pour les services populaires (pas de mock, juste un mapping UI)
struct PopularServiceUI: Hashable {
    let name: String
    let estimatedEarnings: Double
    let count: Int
}
