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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return bookings.compactMap { booking in
            guard let date = formatter.date(from: booking.date) else { return nil }
            
            let signedAmount: Double
            switch booking.paymentStatus {
            case .refunded:
                signedAmount = booking.price        // remboursement +
            default:
                signedAmount = -booking.price       // paiement -
            }
            
            return PaymentTransaction(
                id: booking.id,
                title: booking.serviceName,
                date: date,
                amount: signedAmount
            )
        }
    }
    
    static var sampleValues: [PaymentTransaction] {
        fromBookings(Booking.sampleValues)
    }
}
