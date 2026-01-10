//
//  VehicleProfileView.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import SwiftUI
import RswiftResources

struct VehicleProfileView: View {
    let vehicleProfile: VehicleProfile
    let engine: Engine
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec type de véhicule
                    vehicleHeader
                    
                    // Informations du véhicule
                    vehicleInfoSection
                    
                    // Statistiques
                    statisticsSection
                    
                    // Historique des services
                    if !vehicleProfile.pastServices.isEmpty {
                        historySection
                    } else {
                        emptyHistoryView
                    }
                    
                    // Préférences
                    preferencesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mon Véhicule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Vehicle Header
    
    private var vehicleHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: vehicleProfile.vehicleType.icon)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text(vehicleProfile.vehicleType.localizedName)
                .font(.system(size: 28, weight: .bold))
            
            if let make = vehicleProfile.make, let model = vehicleProfile.model {
                Text("\(make) \(model)")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            
            if let year = vehicleProfile.year {
                Text("\(year)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Vehicle Info Section
    
    private var vehicleInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.system(size: 20, weight: .bold))
            
            if let color = vehicleProfile.color {
                infoRow(icon: "paintbrush.fill", label: "Couleur", value: color)
            }
            
            if let licensePlate = vehicleProfile.licensePlate {
                infoRow(icon: "number", label: "Plaque", value: licensePlate)
            }
            
            if let firstService = vehicleProfile.firstServiceDate {
                infoRow(icon: "calendar", label: "Premier service", value: formatDate(firstService))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiques")
                .font(.system(size: 20, weight: .bold))
            
            HStack(spacing: 20) {
                statCard(
                    icon: "checkmark.circle.fill",
                    value: "\(vehicleProfile.totalServicesCount)",
                    label: "Services",
                    color: .blue
                )
                
                statCard(
                    icon: "eurosign.circle.fill",
                    value: String(format: "%.0f", vehicleProfile.totalSpent),
                    label: "Total dépensé",
                    color: .green
                )
                
                statCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", vehicleProfile.averageServicePrice),
                    label: "Moyenne",
                    color: .orange
                )
            }
            
            if let mostUsed = vehicleProfile.mostUsedService {
                infoRow(icon: "sparkles", label: "Service préféré", value: mostUsed)
            }
            
            if let favoriteProvider = vehicleProfile.favoriteProvider {
                infoRow(icon: "person.fill", label: "Provider préféré", value: favoriteProvider)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - History Section
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historique des services")
                .font(.system(size: 20, weight: .bold))
            
            ForEach(vehicleProfile.pastServices.prefix(10)) { service in
                serviceHistoryRow(service: service)
            }
            
            if vehicleProfile.pastServices.count > 10 {
                Text("Et \(vehicleProfile.pastServices.count - 10) autres services...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func serviceHistoryRow(service: VehicleServiceHistory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(service.serviceName)
                    .font(.system(size: 16, weight: .semibold))
                
                Text("\(service.providerName) • \(formatDate(service.date))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(String(format: "%.2f", service.price)) €")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Préférences")
                .font(.system(size: 20, weight: .bold))
            
            if let notes = vehicleProfile.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(notes)
                        .font(.system(size: 15))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            if let instructions = vehicleProfile.specialInstructions, !instructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions spéciales")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(instructions)
                        .font(.system(size: 15))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Empty History View
    
    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text("Aucun service pour l'instant")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Votre historique de services apparaîtra ici après votre premier service.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper Views
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
        }
    }
    
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

