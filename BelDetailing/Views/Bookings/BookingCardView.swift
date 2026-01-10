//
//  BookingCardView.swift
//  BelDetailing
//
//  Redesign style e-commerce avec banner du detailer à gauche
//

import SwiftUI
import RswiftResources

struct BookingCardView: View {
    let booking: Booking
    let onManage: () -> Void
    let onCancel: () -> Void
    let onRepeat: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // --- IMAGE (Banner du detailer) à gauche ---
            bookingImage
            
            // --- CONTENU à droite ---
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Nom du provider
                Text(booking.displayProviderName)
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .lineLimit(1)
                
                // Prix
                Text(formatPrice(booking.price, currency: booking.currency))
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                // Service name
                if let serviceName = booking.serviceName {
                    Text(serviceName)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Actions
                bookingActions
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(height: 160)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: DesignSystem.Colors.shadow, radius: 4, y: 2)
        .overlay(
            // Badge de statut en haut à droite
            VStack {
                HStack {
                    Spacer()
                    BookingStatusBadge(status: booking.status, paymentStatus: booking.paymentStatus)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.sm)
        )
    }
    
    // MARK: - Booking Image (Banner du detailer)
    
    private var bookingImage: some View {
        Group {
            if let bannerUrl = booking.providerBannerUrl,
               let url = URL(string: bannerUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        imagePlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 120, height: 120)
        .clipped()
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium,
                style: .continuous
            )
        )
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "car.fill")
                .font(.system(size: 32))
                .foregroundColor(DesignSystem.Colors.secondaryText.opacity(0.5))
        }
    }
    
    // MARK: - Booking Actions
    
    @ViewBuilder
    private var bookingActions: some View {
        if booking.status == .completed {
            // Bouton "Réserver à nouveau"
            Button(action: onRepeat) {
                Text(R.string.localizable.bookingBookAgain())
                    .font(DesignSystem.Typography.buttonSecondary)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            }
            .buttonStyle(.plain)
        } else {
            // Boutons "Gérer" et "Annuler"
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button(action: onManage) {
                    Text(R.string.localizable.bookingManage())
                        .font(DesignSystem.Typography.buttonSecondary)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                }
                .buttonStyle(.plain)
                
                Button(action: onCancel) {
                    Text(R.string.localizable.bookingCancel())
                        .font(DesignSystem.Typography.buttonSecondary)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.error)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.uppercased()
        formatter.locale = Locale(identifier: currency == "eur" ? "fr_FR" : "en_US")
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) \(currency.uppercased())"
    }
}
