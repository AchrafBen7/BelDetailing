//
//  PaymentCashOrCard.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//
import SwiftUI
import RswiftResources

enum Payment: CaseIterable {
    case card, paypal, applePay, cash

    var title: String {
        switch self {
        case .card: return R.string.localizable.paymentCard()
        case .paypal: return "PayPal"
        case .applePay: return "Apple Pay"
        case .cash: return R.string.localizable.paymentCash()
        }
    }

    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .paypal: return "p.square"     // icône PayPal SF Symbol alternative
        case .applePay: return "apple.logo"
        case .cash: return "banknote"
        }
    }
}
