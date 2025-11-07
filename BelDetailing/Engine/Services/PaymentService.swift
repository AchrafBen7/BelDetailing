//
//  PaymentService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Protocol
protocol PaymentService {
    /// Crée une pré-autorisation Stripe pour une réservation donnée
    func createPaymentIntent(for bookingId: String, amount: Double, currency: String) async -> APIResponse<PaymentIntent>
    
    /// Capture (débloque) le paiement après réalisation du service
    func capturePayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool>
    
    /// Annule ou rembourse une pré-autorisation
    func refundPayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool>
}

// MARK: - Network Implementation
final class PaymentServiceNetwork: PaymentService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func createPaymentIntent(for bookingId: String, amount: Double, currency: String) async -> APIResponse<PaymentIntent> {
        let body: [String: Any] = [
            "bookingId": bookingId,
            "amount": amount,
            "currency": currency
        ]
        return await networkClient.call(endPoint: .paymentIntent, dict: body)
    }
    
    func capturePayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool> {
        let endpoint = APIEndPoint.bookingConfirm(id: bookingId)
        return await networkClient.call(endPoint: endpoint, dict: ["paymentIntentId": paymentIntentId])
    }
    
    func refundPayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool> {
        // Endpoint futur : /api/v1/payments/refund
        return await networkClient.call(endPoint: .bookingCancel(id: bookingId), dict: ["paymentIntentId": paymentIntentId])
    }
}

// MARK: - Mock Implementation
final class PaymentServiceMock: MockService, PaymentService {
    func createPaymentIntent(for bookingId: String, amount: Double, currency: String) async -> APIResponse<PaymentIntent> {
        await randomWait()
        let mockIntent = PaymentIntent(
            id: "pi_mock_\(bookingId)",
            clientSecret: "cs_test_\(Int.random(in: 1000...9999))",
            amount: amount,
            currency: currency,
            status: "requires_confirmation"
        )
        return .success(mockIntent)
    }
    
    func capturePayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool> {
        await randomWait()
        print("💳 [MOCK] Capture du paiement \(paymentIntentId) pour la réservation \(bookingId)")
        return .success(true)
    }
    
    func refundPayment(for bookingId: String, paymentIntentId: String) async -> APIResponse<Bool> {
        await randomWait()
        print("💸 [MOCK] Remboursement du paiement \(paymentIntentId) pour la réservation \(bookingId)")
        return .success(true)
    }
}
