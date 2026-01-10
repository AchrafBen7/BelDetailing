//
//  BookingConfirmedView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//  Updated: Design minimaliste style Uber avec récapitulatif détaillé
//

import SwiftUI
import RswiftResources

// MARK: - Booking Confirmation Data

struct BookingConfirmationData {
    let bookingId: String?
    let providerName: String
    let serviceName: String
    let price: Double
    let currency: String
    let date: String
    let startTime: String?
    let endTime: String?
    let address: String
    let paymentMethod: String? // "card" ou "cash"
    let isMultiService: Bool
    let servicesCount: Int
}

struct BookingConfirmedView: View {
    let engine: Engine
    let confirmationData: BookingConfirmationData?
    
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @Binding var tabSelection: MainTabView.Tab
    @Environment(\.dismiss) private var dismiss
    @State private var booking: Booking?
    
    init(
        engine: Engine,
        tabSelection: Binding<MainTabView.Tab>,
        confirmationData: BookingConfirmationData? = nil
    ) {
        self.engine = engine
        self._tabSelection = tabSelection
        self.confirmationData = confirmationData
    }
    
    var body: some View {
        ZStack {
            // Fond avec illustration subtile (style Uber)
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header simple
                header
                
                // Contenu scrollable
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Carte de confirmation principale
                        if let data = confirmationData ?? bookingData {
                            confirmationCard(data: data)
                        } else {
                            // Fallback si pas de données
                            basicConfirmationView
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, 100) // Espace pour le bouton fixe en bas
                }
                
                // Bouton fixe en bas
                VStack(spacing: 0) {
                    Divider()
                        .background(DesignSystem.Colors.border)
                    
                    Button {
                        // 1. Change l'onglet
                        tabSelection = .bookings
                        
                        // 2. Ferme TOUT le flow (Step3, Step2, Step1)
                        dismiss()
                        dismiss()
                        dismiss()
                    } label: {
                        Text("Voir mes réservations")
                            .font(DesignSystem.Typography.buttonCTA)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.cardBackground)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // Si on a un bookingId, charger les détails
            if let bookingId = confirmationData?.bookingId {
                await loadBookingDetails(bookingId: bookingId)
            }
        }
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                // Fermer toutes les vues de réservation
                dismiss()
                dismiss()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.cardBackground)
    }
    
    // MARK: - Confirmation Card (Style Uber)
    
    private func confirmationCard(data: BookingConfirmationData) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Titre
            Text("Votre demande de réservation")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, DesignSystem.Spacing.xs)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Service et Statut
            serviceStatusSection(data: data)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Date et Heure
            dateTimeSection(data: data)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Adresse
            addressSection(data: data)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Méthode de paiement
            paymentMethodSection(data: data)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // ⚠️ Message Important - Demande de réservation
            infoMessageSection()
        }
        .cardStyle(
            padding: DesignSystem.Spacing.lg,
            cornerRadius: DesignSystem.CornerRadius.large
        )
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    // MARK: - Basic Confirmation View (Fallback)
    
    private var basicConfirmationView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 90, height: 90)
                .foregroundColor(DesignSystem.Colors.success)
            
            Text(R.string.localizable.bookingConfirmedTitle())
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(R.string.localizable.bookingConfirmedSubtitle())
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
    
    // MARK: - Computed Properties
    
    private var bookingData: BookingConfirmationData? {
        guard let booking = booking else { return nil }
        
        return BookingConfirmationData(
            bookingId: booking.id,
            providerName: booking.providerName ?? "Prestataire",
            serviceName: booking.serviceName ?? "Service",
            price: booking.price,
            currency: booking.currency,
            date: booking.date,
            startTime: booking.startTime,
            endTime: booking.endTime,
            address: booking.address,
            paymentMethod: booking.paymentMethod?.rawValue,
            isMultiService: false,
            servicesCount: 1
        )
    }
    
    // MARK: - Helper Functions
    
    private func loadBookingDetails(bookingId: String) async {
        let result = await engine.bookingService.getBookingDetail(id: bookingId)
        if case .success(let loadedBooking) = result {
            await MainActor.run {
                booking = loadedBooking
            }
        }
    }
    
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
        // Format: "HH:mm" -> "HHhmm"
        let components = time.split(separator: ":")
        if components.count == 2,
           let hour = Int(components[0]),
           let minute = Int(components[1]) {
            return String(format: "%02dh%02d", hour, minute)
        }
        return time
    }
}
