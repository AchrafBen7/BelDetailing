//
//  AddPaymentMethodView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Design personnalisé style Uber pour ajouter une carte
//

import SwiftUI
import UIKit
import StripePaymentSheet
import RswiftResources

enum PaymentMethodType: String, CaseIterable {
    case bankCard = "Bank card"
    case applePay = "Apple Pay"
    case googlePay = "Google Pay"
    case samsungPay = "Samsung Pay"
    
    var icon: String {
        switch self {
        case .bankCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .googlePay: return "g.circle.fill"
        case .samsungPay: return "s.circle.fill"
        }
    }
}

struct AddPaymentMethodView: View {
    let engine: Engine
    let onCardAdded: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var selectedPaymentType: PaymentMethodType = .bankCard
    @State private var cardNumber: String = ""
    @State private var expirationDate: String = ""
    @State private var cvv: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    @State private var paymentSheet: PaymentSheet?
    @State private var isPresentingPaymentSheet = false
    
    // Détection de la marque de carte depuis le numéro
    private var cardBrand: String {
        let cleaned = cardNumber.replacingOccurrences(of: " ", with: "")
        if cleaned.isEmpty { return "VISA" }
        
        if cleaned.hasPrefix("4") { return "VISA" }
        if cleaned.hasPrefix("5") || cleaned.hasPrefix("2") { return "MASTERCARD" }
        if cleaned.hasPrefix("3") { return "AMEX" }
        return "VISA"
    }
    
    // Formatage du numéro de carte (utilisé pour l'affichage uniquement)
    private func formatCardNumber(_ input: String) -> String {
        let cleaned = input.replacingOccurrences(of: " ", with: "")
        var formatted = ""
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        return formatted
    }
    
    // Derniers 4 chiffres pour l'affichage
    private var last4Digits: String {
        let cleaned = cardNumber.replacingOccurrences(of: " ", with: "")
        if cleaned.count >= 4 {
            return String(cleaned.suffix(4))
        }
        return "0380"
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Sélection du type de paiement
                        paymentTypeSelector
                        
                        // Section "Add new card"
                        if selectedPaymentType == .bankCard {
                            addNewCardSection
                        } else {
                            // Pour Apple Pay, Google Pay, Samsung Pay
                            walletPaymentSection
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, 100) // Espace pour le bouton fixe
                }
                
                // Bouton "Save card" fixe en bas
                if selectedPaymentType == .bankCard {
                    saveCardButton
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage ?? "Une erreur est survenue")
        }
        .background(
            Group {
                if let sheet = paymentSheet {
                    PaymentSheetHost(
                        isPresented: $isPresentingPaymentSheet,
                        paymentSheet: sheet,
                        onResult: handlePaymentSheetResult
                    )
                }
            }
        )
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("Your cards")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Spacer()
            
            // Bouton + (pour future fonctionnalité)
            Button {
                // Peut être utilisé pour ajouter d'autres types de cartes
            } label: {
                Image(systemName: "plus")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(DesignSystem.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
    }
    
    // MARK: - Payment Type Selector
    
    private var paymentTypeSelector: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(PaymentMethodType.allCases, id: \.self) { type in
                Button {
                    selectedPaymentType = type
                } label: {
                    Text(type.rawValue)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(
                            selectedPaymentType == type
                                ? DesignSystem.Colors.primaryText
                                : DesignSystem.Colors.secondaryText
                        )
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            selectedPaymentType == type
                                ? Color(red: 1.0, green: 0.843, blue: 0.0) // Jaune doré #FFD700
                                : DesignSystem.Colors.cardBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                }
            }
        }
    }
    
    // MARK: - Add New Card Section
    
    private var addNewCardSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Titre "Add new card"
            Text("Add new card")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            // Représentation visuelle de la carte (NOIRE)
            cardVisualRepresentation
            
            // Champs de saisie
            VStack(spacing: DesignSystem.Spacing.md) {
                // Numéro de carte
                cardNumberField
                
                // Date d'expiration
                expirationDateField
                
                // CVV
                cvvField
            }
        }
    }
    
    // MARK: - Card Visual Representation (NOIRE)
    
    private var cardVisualRepresentation: some View {
        CardVisualRepresentation(
            cardBrand: cardBrand,
            last4Digits: last4Digits,
            expirationDate: expirationDate
        )
    }
    
    // MARK: - Input Fields
    
    private var cardNumberField: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Logo de la carte
            Image(systemName: "creditcard.fill")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .onChange(of: cardNumber) { newValue in
                    // Limiter à 16 chiffres + espaces
                    let cleaned = newValue.replacingOccurrences(of: " ", with: "")
                    if cleaned.count > 16 {
                        cardNumber = formatCardNumber(String(cleaned.prefix(16)))
                    } else {
                        cardNumber = formatCardNumber(cleaned)
                    }
                }
            
            if !cardNumber.isEmpty {
                Button {
                    cardNumber = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    
    private var expirationDateField: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            TextField("MM / YY", text: $expirationDate)
                .keyboardType(.numberPad)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .onChange(of: expirationDate) { newValue in
                    // Format MM / YY
                    let cleaned = newValue.replacingOccurrences(of: " / ", with: "")
                        .replacingOccurrences(of: "/", with: "")
                        .replacingOccurrences(of: " ", with: "")
                    
                    if cleaned.count <= 4 {
                        if cleaned.isEmpty {
                            expirationDate = ""
                        } else if cleaned.count <= 2 {
                            expirationDate = cleaned
                        } else {
                            let month = String(cleaned.prefix(2))
                            let year = String(cleaned.suffix(min(2, cleaned.count - 2)))
                            expirationDate = month + " / " + year
                        }
                    } else {
                        let month = String(cleaned.prefix(2))
                        let year = String(cleaned.dropFirst(2).prefix(2))
                        expirationDate = month + " / " + year
                    }
                }
            
            if !expirationDate.isEmpty {
                Button {
                    expirationDate = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    
    private var cvvField: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            SecureField("CVV", text: $cvv)
                .keyboardType(.numberPad)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .onChange(of: cvv) { newValue in
                    // Limiter à 3-4 chiffres
                    let cleaned = newValue.replacingOccurrences(of: " ", with: "")
                    if cleaned.count > 4 {
                        cvv = String(cleaned.prefix(4))
                    } else {
                        cvv = cleaned
                    }
                }
            
            if !cvv.isEmpty {
                Button {
                    cvv = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
    
    // MARK: - Wallet Payment Section (Apple Pay, etc.)
    
    private var walletPaymentSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: selectedPaymentType.icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text("\(selectedPaymentType.rawValue) sera disponible prochainement")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }
    
    // MARK: - Save Card Button
    
    private var saveCardButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(DesignSystem.Colors.border)
            
            Button {
                Task {
                    await saveCard()
                }
            } label: {
                Text("Save card")
                    .font(DesignSystem.Typography.buttonCTA)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            }
            .buttonStyle(.plain)
            .disabled(!isFormValid || isLoading)
            .opacity(isFormValid && !isLoading ? 1.0 : 0.5)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpiration = expirationDate.replacingOccurrences(of: " / ", with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        return cleanedCardNumber.count == 16
            && cleanedExpiration.count == 4
            && cvv.count >= 3
    }
    
    // MARK: - Actions
    
    private func saveCard() async {
        isLoading = true
        defer { isLoading = false }
        
        // Utiliser Stripe PaymentSheet en arrière-plan
        let result = await engine.paymentService.createSetupIntent()
        
        switch result {
        case .success(let setup):
            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "BelDetailing"
            config.customer = .init(
                id: setup.customerId,
                ephemeralKeySecret: setup.ephemeralKeySecret
            )
            config.allowsDelayedPaymentMethods = false
            
            let sheet = PaymentSheet(
                setupIntentClientSecret: setup.setupIntentClientSecret,
                configuration: config
            )
            
            self.paymentSheet = sheet
            await Task.yield()
            self.isPresentingPaymentSheet = true
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handlePaymentSheetResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            onCardAdded()
            dismiss()
            
        case .failed(let error):
            errorMessage = error.localizedDescription
            showError = true
            
        case .canceled:
            break
        }
        
        paymentSheet = nil
        isPresentingPaymentSheet = false
    }
}


