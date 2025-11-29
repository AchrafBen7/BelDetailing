//
//  PaymentMethode.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

import Foundation

struct PaymentMethod: Codable, Identifiable, Hashable {
    let id: String
    let brand: String          // "Visa", "Mastercard"…
    let last4: String
    let expMonth: Int
    let expYear: Int
    let isDefault: Bool
}

extension PaymentMethod {
    static let sampleValues: [PaymentMethod] = [
        PaymentMethod(
            id: "pm_visa_4242",
            brand: "Visa",
            last4: "4242",
            expMonth: 12,
            expYear: 2025,
            isDefault: true
        ),
        PaymentMethod(
            id: "pm_mc_8888",
            brand: "Mastercard",
            last4: "8888",
            expMonth: 6,
            expYear: 2026,
            isDefault: false
        )
    ]
}
