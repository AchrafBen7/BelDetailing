//
//  TransactionDetailViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine
import SwiftUI
import RswiftResources

@MainActor
final class TransactionDetailViewModel: ObservableObject {
    @Published var isProcessingRefund = false
    @Published var errorMessage: String?
    @Published var paymentIntentId: String?
    
    private let transaction: PaymentTransaction
    private let engine: Engine
    
    init(transaction: PaymentTransaction, engine: Engine) {
        self.transaction = transaction
        self.engine = engine
        // TODO: Récupérer paymentIntentId depuis le backend si disponible
    }
    
    var canRefund: Bool {
        // Peut rembourser si:
        // 1. C'est un paiement (pas un refund déjà)
        // 2. Le statut est "paid" ou "succeeded"
        // 3. Pas déjà remboursé
        transaction.type.lowercased() == "payment" &&
        (transaction.status.lowercased() == "paid" || transaction.status.lowercased() == "succeeded") &&
        transaction.status.lowercased() != "refunded"
    }
    
    var icon: String {
        switch transaction.type.lowercased() {
        case "payment": return "creditcard.fill"
        case "refund": return "arrow.uturn.left.circle.fill"
        case "payout": return "banknote.fill"
        default: return "doc.fill"
        }
    }
    
    var iconColor: Color {
        switch transaction.type.lowercased() {
        case "payment": return .green
        case "refund": return .red
        case "payout": return .blue
        default: return .gray
        }
    }
    
    var typeText: String {
        switch transaction.type.lowercased() {
        case "payment": return R.string.localizable.transactionTypePayment()
        case "refund": return R.string.localizable.transactionTypeRefund()
        case "payout": return R.string.localizable.transactionTypePayout()
        default: return R.string.localizable.transactionTypeTransaction()
        }
    }
    
    var statusText: String {
        switch transaction.status.lowercased() {
        case "succeeded", "paid": return R.string.localizable.transactionStatusSucceeded()
        case "pending": return R.string.localizable.transactionStatusPending()
        case "failed": return R.string.localizable.transactionStatusFailed()
        case "refunded": return R.string.localizable.transactionStatusRefunded()
        case "processing": return R.string.localizable.transactionStatusProcessing()
        default: return R.string.localizable.transactionStatusUnknown()
        }
    }
    
    var statusColor: Color {
        switch transaction.status.lowercased() {
        case "succeeded", "paid": return .green
        case "pending", "processing": return .orange
        case "failed": return .red
        case "refunded": return .blue
        default: return .gray
        }
    }
    
    var formattedAmount: String {
        let sign = transaction.type.lowercased() == "refund" ? "-" : "+"
        let amountStr = String(format: "%.2f", transaction.amount)
        return "\(sign)\(amountStr) \(transaction.currency.uppercased())"
    }
    
    var amountColor: Color {
        transaction.type.lowercased() == "refund" ? .red : .green
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: transaction.createdAt)
    }
    
    func requestRefund() async {
        guard canRefund else {
            errorMessage = "transactionRefundNotAllowed"
            return
        }
        
        guard let paymentIntentId = paymentIntentId else {
            // Si pas de paymentIntentId, on essaie avec l'ID de la transaction
            // Le backend devrait gérer ça
            await performRefund(paymentIntentId: transaction.id)
            return
        }
        
        await performRefund(paymentIntentId: paymentIntentId)
    }
    
    private func performRefund(paymentIntentId: String) async {
        isProcessingRefund = true
        errorMessage = nil
        
        let result = await engine.paymentService.refundPayment(paymentIntentId: paymentIntentId)
        
        isProcessingRefund = false
        
        switch result {
        case .success:
            errorMessage = nil
            // Notification de refund
            NotificationsManager.shared.notifyRefundProcessed(
                transactionId: paymentIntentId,
                amount: transaction.amount
            )
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

