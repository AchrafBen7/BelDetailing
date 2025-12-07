//  Invoice.swift

import Foundation

struct Invoice: Identifiable, Hashable {
    let id: String
    let title: String
    let amount: Double
    let date: Date
}

extension Invoice { // Readfortune1@gmail.com et Achrouf1208.
    static func fromBookings(_ bookings: [Booking]) -> [Invoice] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return bookings.compactMap { booking in
            guard let date = formatter.date(from: booking.date) else { return nil }
            return Invoice(
                id: "INV-\(booking.id)",
                title: booking.serviceName,
                amount: booking.price,
                date: date
            )
        }
    }
    
}
