//
//  PaymentIntent.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

struct PaymentIntent: Codable, Identifiable, Hashable {
    let id: String
    let clientSecret: String
    let amount: Double
    let currency: String
    let status: String      // e.g. "requires_confirmation", "succeeded", "canceled"
}
