//
//  PaymentMethode.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

import Foundation

struct AppPaymentMethod: Codable, Identifiable, Hashable {
    let id: String
    let brand: String
    let last4: String
    let expMonth: Int
    let expYear: Int
    let isDefault: Bool

    var displayName: String {
        brand.capitalized + " •••• \(last4)"
    }

    var iconName: String {
        switch brand.lowercased() {
        case "visa": return "visa"
        case "mastercard": return "mastercard"
        case "amex": return "amex"
        default: return "creditcard"
        }
    }
}

extension AppPaymentMethod {
    var expiryFormatted: String {
        String(format: "%02d/%d", expMonth, expYear)
    }
}
