//
//  PaymentTransaction.swift
//  BelDetailing
//

import Foundation

struct PaymentTransaction: Identifiable, Hashable {
    let id: String
    let title: String
    let date: Date
    let amount: Double    // négatif = débité, positif = remboursement
}

// MARK: - Helpers + Samples

extension PaymentTransaction {
    static func fromBookings(_ bookings: [Booking]) -> [PaymentTransaction] {
        return bookings.compactMap { booking in
            guard let date = DateFormatters.isoDate(booking.date) else { return nil }
            
            let signedAmount: Double
            switch booking.paymentStatus {
            case .refunded:
                signedAmount = booking.price        // remboursement +
            default:
                signedAmount = -booking.price       // paiement -
            }
            
            let title = booking.serviceName ?? (booking.providerName ?? "Service")
            
            return PaymentTransaction(
                id: booking.id,
                title: title,
                date: date,
                amount: signedAmount
            )
        }
    }
    
}
