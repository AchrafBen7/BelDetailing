//
//  NoShowResponse.swift
//  BelDetailing
//
//  Réponse du backend pour le no-show
//

import Foundation

struct NoShowResponse: Codable {
    let success: Bool
    let partialPaymentAmount: Double
    let bookingId: String
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case partialPaymentAmount = "partial_payment_amount"
        case bookingId = "booking_id"
        case message
    }
}

