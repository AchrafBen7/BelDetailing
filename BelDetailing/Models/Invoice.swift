//  Invoice.swift

import Foundation

struct Invoice: Identifiable, Hashable {
    let id: String
    let title: String
    let amount: Double
    let date: Date
}

extension Invoice { 
    static func fromBookings(_ bookings: [Booking]) -> [Invoice] {
        bookings.compactMap { booking in
            guard let date = DateFormatters.isoDate(booking.date) else { return nil }
            let title = booking.serviceName ?? (booking.providerName ?? "Service")
            return Invoice(
                id: "INV-\(booking.id)",
                title: title,
                amount: booking.price,
                date: date
            )
        }
    }
    
}
