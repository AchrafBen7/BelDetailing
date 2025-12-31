//
//  EditProfileMetricsView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct EditProfileMetricsView: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            MetricCard(
                icon: "star.fill",
                value: formatRating(viewModel.providerRating),
                label: R.string.localizable.profileMetricRating(),
                iconColor: .yellow
            )
            
            Divider()
                .frame(height: 50)
            
            MetricCard(
                icon: "calendar",
                value: formatExperience(viewModel.providerExperience),
                label: R.string.localizable.profileMetricExperience(),
                iconColor: .blue
            )
            
            Divider()
                .frame(height: 50)
            
            MetricCard(
                icon: "person.3.fill",
                value: formatTeamSize(viewModel.providerTeamSizeValue),
                label: R.string.localizable.profileMetricTeam(),
                iconColor: .green
            )
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func formatRating(_ rating: Double?) -> String {
        guard let rating = rating, rating > 0 else { return "—" }
        return String(format: "%.1f", rating)
    }
    
    private func formatExperience(_ years: Int?) -> String {
        guard let years = years, years > 0 else { return "—" }
        return "\(years) \(R.string.localizable.profileMetricYears())"
    }
    
    private func formatTeamSize(_ size: Int?) -> String {
        guard let size = size, size > 0 else { return "—" }
        return "\(size)"
    }
}

// MARK: - Extensions
private extension EditProfileViewModel {
    var providerRating: Double? {
        // TODO: Load from provider detail if needed
        nil
    }
    
    var providerExperience: Int? {
        providerYearsOfExperience > 0 ? providerYearsOfExperience : nil
    }
    
    var providerTeamSizeValue: Int? {
        providerTeamSize > 0 ? providerTeamSize : nil
    }
}

