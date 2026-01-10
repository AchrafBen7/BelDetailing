//
//  BookingConfirmedCardComponents.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Composants extraits de BookingConfirmedView pour respecter la limite de longueur
//

import SwiftUI
import RswiftResources

// MARK: - Confirmation Card Components

extension BookingConfirmedView {
    
    // MARK: - Service and Status Section
    
    func serviceStatusSection(data: BookingConfirmationData) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: "car.fill")
                .font(.system(size: 24))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(data.serviceName)
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("En attente de confirmation")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.warning)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                Text(formatPrice(data.price, currency: data.currency))
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                if data.isMultiService {
                    Text("\(data.servicesCount) services")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
    }
    
    // MARK: - Date and Time Section
    
    func dateTimeSection(data: BookingConfirmationData) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Planifié pour")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(formatDateAndTime(data.date, startTime: data.startTime))
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                if let endTime = data.endTime {
                    Text("Fin prévue: \(formatTime(endTime))")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Address Section
    
    func addressSection(data: BookingConfirmationData) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                VStack(spacing: 0) {
                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 12, height: 12)
                    Rectangle()
                        .fill(DesignSystem.Colors.border)
                        .frame(width: 2)
                        .frame(height: 40)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Adresse de service")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    Text(data.address)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(2)
                }
            }
        }
    }
    
    // MARK: - Payment Method Section
    
    func paymentMethodSection(data: BookingConfirmationData) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: data.paymentMethod == "cash" ? "banknote.fill" : "creditcard.fill")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Méthode de paiement")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(data.paymentMethod == "cash" ? "Espèces" : "Carte bancaire")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Info Message Section
    
    func infoMessageSection() -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.info)
                
                Text("Demande de réservation")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Votre demande a été envoyée au prestataire.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Le prestataire doit confirmer votre demande avant que le paiement ne soit effectué. Si votre demande est refusée, aucun montant ne sera prélevé de votre compte.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Colors.info.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(DesignSystem.Colors.info.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    
    // MARK: - Helper Functions (delegated to main view)
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.uppercased()
        formatter.locale = Locale(identifier: currency == "eur" ? "fr_FR" : "en_US")
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) \(currency.uppercased())"
    }
    
    private func formatDateAndTime(_ date: String, startTime: String?) -> String {
        guard let dateObj = DateFormatters.isoDate(date) else {
            return date
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "fr_FR")
        displayFormatter.dateFormat = "EEE, d MMM"
        
        var result = displayFormatter.string(from: dateObj)
        
        if let time = startTime {
            result += ", \(formatTime(time))"
        }
        
        return result
    }
    
    private func formatTime(_ time: String) -> String {
        let components = time.split(separator: ":")
        if components.count == 2,
           let hour = Int(components[0]),
           let minute = Int(components[1]) {
            return String(format: "%02dh%02d", hour, minute)
        }
        return time
    }
}

