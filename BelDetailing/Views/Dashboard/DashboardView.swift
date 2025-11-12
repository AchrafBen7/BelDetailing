//  DashboardView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI
import RswiftResources

struct DashboardView: View {
    let engine: Engine
    @State private var stats: DetailerStats?
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if let stats = stats {
                        statsGrid(stats)
                    } else if isLoading {
                        ProgressView("Chargement des données…")
                            .padding(.top, 60)
                    } else {
                        Text("Impossible de charger les statistiques.")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .background(Color(R.color.mainBackground.name))
            .navigationTitle("Tableau de bord")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadStats() }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bienvenue,")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Votre activité")
                .font(.largeTitle.bold())
                .foregroundColor(Color(R.color.primaryText))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Grid
    private func statsGrid(_ stats: DetailerStats) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                statCard(title: "Réservations", value: "\(stats.totalBookings)", icon: "calendar")
                statCard(title: "Terminées", value: "\(stats.completedBookings)", icon: "checkmark.circle.fill", color: .green)
            }

            HStack(spacing: 16) {
                statCard(title: "Avis", value: "\(stats.totalReviews)", icon: "text.bubble.fill", color: .blue)
                statCard(title: "Note moyenne", value: String(format: "%.1f ★", stats.ratingAverage), icon: "star.fill", color: .yellow)
            }

            HStack(spacing: 16) {
                statCard(title: "Offres actives", value: "\(stats.activeOffers)", icon: "briefcase.fill", color: .orange)
                statCard(title: "Revenus du mois", value: "€\(Int(stats.revenueMonth))", icon: "eurosign.circle.fill", color: .purple)
            }
        }
    }

    // MARK: - Stat Card
    private func statCard(title: String, value: String, icon: String, color: Color = .accentColor) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 22, weight: .semibold))
                Spacer()
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(Color(R.color.primaryText))
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Data Fetch
    private func loadStats() async {
        isLoading = true
        let response = await engine.detailerService.getStats(id: "provider_001")

        await MainActor.run {
            switch response {
            case .success(let stats):
                self.stats = stats
            case .failure:
                self.stats = nil
            }
            isLoading = false
        }
    }
}

#Preview {
    DashboardView(engine: Engine(mock: true))
}
