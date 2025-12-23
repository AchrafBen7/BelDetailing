//
//  PaymentTransaction.swift
//  BelDetailing
//

import Foundation

struct PaymentTransaction: Identifiable, Codable, Hashable {
    let id: String
    let amount: Double
    let currency: String
    let status: String
    let type: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency
        case status
        case type
        case createdAt = "created_at"
    }
}
