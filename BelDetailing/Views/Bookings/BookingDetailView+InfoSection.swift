//
//  BookingDetailView+InfoSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

extension BookingDetailView {
    // MARK: - Booking Info Section
    var bookingInfoSection: some View {
        let isProvider = session.user?.role == .provider
        let isAccepted = booking.status == .confirmed || booking.status == .started || booking.status == .inProgress || booking.status == .completed
        
        return VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingDetailInformation())
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 12) {
                InfoRow(label: R.string.localizable.bookingDetailService(), value: booking.displayServiceName)
                
                if isProvider {
                    // Pour le provider : afficher le nom du customer seulement si accepté
                    if isAccepted, let customer = booking.customer {
                        InfoRow(label: "Client", value: "\(customer.firstName) \(customer.lastName)")
                    } else {
                        InfoRow(label: "Client", value: "Informations masquées")
                    }
                } else {
                    InfoRow(label: R.string.localizable.bookingDetailProvider(), value: booking.displayProviderName)
                }
                
                InfoRow(label: R.string.localizable.bookingDetailDate(), value: DateFormatters.humanDate(from: booking.date, time: booking.displayStartTime))
                
                if isProvider {
                    // Pour le provider : afficher seulement la ville si pas accepté
                    if isAccepted {
                        InfoRow(label: R.string.localizable.bookingDetailAddress(), value: booking.address)
                    } else {
                        let city = extractCity(from: booking.address)
                        InfoRow(label: "Ville", value: city.isEmpty ? "—" : city)
                    }
                } else {
                    InfoRow(label: R.string.localizable.bookingDetailAddress(), value: booking.address)
                }
                
                InfoRow(label: R.string.localizable.bookingDetailPrice(), value: String(format: "%.2f €", booking.price))
                
                // Type de véhicule (visible pour le provider même si pas accepté)
                if isProvider, let customer = booking.customer, let vehicleType = customer.vehicleType {
                    HStack {
                        Image(systemName: vehicleType.icon)
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Text("Type de véhicule")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(vehicleType.localizedName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                
                // Informations sensibles (seulement si accepté pour le provider)
                if isProvider && isAccepted, let customer = booking.customer {
                    Divider()
                        .padding(.vertical, 4)
                    
                    InfoRow(label: "Email", value: customer.email)
                    InfoRow(label: "Téléphone", value: customer.phone)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper: Extract city from address
    func extractCity(from address: String) -> String {
        // Simple extraction: prendre la partie après la dernière virgule, ou le dernier mot
        let components = address.split(separator: ",")
        if let lastComponent = components.last {
            let trimmed = lastComponent.trimmingCharacters(in: .whitespacesAndNewlines)
            // Si c'est un code postal + ville (ex: "1000 Bruxelles"), prendre juste la ville
            let parts = trimmed.split(separator: " ")
            if parts.count > 1, let postalCode = Int(parts[0]) {
                // C'est un code postal, prendre le reste
                return parts.dropFirst().joined(separator: " ")
            }
            return trimmed
        }
        return address
    }
}

