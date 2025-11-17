//
//  ProviderDashboardHeaderView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import RswiftResources


struct ProviderDashboardHeaderView: View {
    let monthlyEarnings: Double
    let variationPercent: Double
    let reservationsCount: Int
    let rating: Double
    let clientsCount: Int
    let onViewOffers: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Ligne : Hello + bouton "Voir offres"
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(R.string.localizable.dashboardHello())
                        .textView(style: .heroTitle, color: .white)
                    
                    Text(R.string.localizable.dashboardActivitySubtitle())
                        .textView(style: .subtitle, color: .white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: onViewOffers) {
                    Text(R.string.localizable.dashboardMyOffers())// 🔁 à mettre en Localizable ensuite
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Capsule())
                }
            }
            
            // Carte blanche des stats
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        R.string.localizable.dashboardEarningsThisMonth()
                            .textView(style: .infoLabel)
                        
                        Text("\(Int(monthlyEarnings))€")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: variationPercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("\(variationPercent >= 0 ? "+" : "")\(Int(variationPercent))%")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(variationPercent >= 0 ? .green : .red)
                        
                        R.string.localizable.dashboardVsLastMonth()
                            .textView(style: .caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    statColumn(
                        value: "\(reservationsCount)",
                        label: R.string.localizable.dashboardStatReservations()
                    )
                    statColumn(
                        value: String(format: "%.1f", rating),
                        label: R.string.localizable.dashboardStatRating()
                    )
                    statColumn(
                        value: "\(clientsCount)",
                        label: R.string.localizable.dashboardStatClients()
                    )
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.10), radius: 12, y: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)     // 👈 plus grand qu’avant (32) → Hello descend
        .padding(.bottom, 24)
        .background(
            RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .textView(style: .caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
