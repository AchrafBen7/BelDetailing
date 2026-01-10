//
//  ProfileDetailComponents.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Metric Card Component
struct ProfileMetricCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section Card Component
struct ProfileSectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Formatting Helpers
func formatProfileRating(_ rating: Double?) -> String {
    guard let rating = rating, rating > 0 else { return "—" }
    return String(format: "%.1f", rating)
}

func formatProfileExperience(_ years: Int?) -> String {
    guard let years = years, years > 0 else { return "—" }
    return "\(years) \(R.string.localizable.profileMetricYears())"
}

func formatProfileTeamSize(_ size: Int?) -> String {
    guard let size = size, size > 0 else { return "—" }
    return "\(size)"
}

