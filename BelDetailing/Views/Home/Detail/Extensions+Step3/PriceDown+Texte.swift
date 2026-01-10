//
//  PriceDown.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
import SwiftUI
import RswiftResources
extension BookingStep3View {

    var priceBreakdownSection: some View {
        // ✅ Utiliser le même calcul que le backend : service.price + transportFee (sans ajustement véhicule)
        let servicePrice = service.price
        let transportFee = calculatedTransportFee
        let totalPrice = servicePrice + transportFee
        
        // Calculer le montant à payer selon la méthode de paiement
        let amountToPay: Double
        if selectedPayment == .cash {
            // Paiement espèces : 20% d'acompte
            amountToPay = totalPrice * 0.20
        } else {
            // Paiement carte : prix complet
            amountToPay = totalPrice
        }
        
        // Vérifier s'il y a une erreur de transport
        let hasTransportError = transportFeeError != nil
        let canProceed = !hasTransportError

        return VStack(alignment: .leading, spacing: 16) {
            // Titre de la section
            Text(R.string.localizable.bookingTotal())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 4)

            // Décomposition du prix
            VStack(alignment: .leading, spacing: 12) {
                // Prix du service
                HStack {
                    Text(R.string.localizable.bookingPriceService())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.2f €", servicePrice))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                }
                
                // Frais de transport (si service à domicile activé)
                if detailer.hasMobileService {
                    if let error = transportFeeError {
                        // Erreur : distance trop grande
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                    } else if let message = transportFeeMessage {
                        // Message informatif selon la zone
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                if transportFee > 0 {
                                    Text(String(format: "+%.2f €", transportFee))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                Text(message)
                                    .font(.system(size: 11))
                                    .foregroundColor(message.contains("gratuit") ? .green : .gray)
                            }
                        }
                    } else if transportFee > 0 {
                        // Affichage simple si pas de message spécial
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "%.2f €", transportFee))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                // Divider
                if detailer.hasMobileService && (transportFee > 0 || transportFeeError != nil) {
                    Divider()
                        .padding(.vertical, 4)
                }
                
                // Total
                HStack {
                    Text(R.string.localizable.bookingTotal())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Text(String(format: "%.2f €", totalPrice))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            // Afficher le montant à payer selon la méthode
            if selectedPayment == .cash {
                Divider()
                    .padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.bookingDeposit())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                        Text(R.string.localizable.bookingDepositRemainder())
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(String(format: "%.2f €", amountToPay))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.orange)
                }
            }

        }
        .padding(.vertical, 20)
        .padding(.horizontal, cardInset)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

extension BookingStep3View {

    var termsSection: some View {
        VStack(spacing: 4) {
            Text(R.string.localizable.bookingTerms1())
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Button(R.string.localizable.bookingTermsConditions()) { }
                    .font(.system(size: 14, weight: .semibold))

                Text(R.string.localizable.bookingTermsAnd())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button(R.string.localizable.bookingTermsCancelPolicy()) { }
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal, 20)
    }
}
