//
//  BookingCancelSheetViewModel.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import Combine

@MainActor
final class BookingCancelSheetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let booking: Booking
    private let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    var refundPercentage: Double {
        booking.refundPercentage
    }
    
    var refundAmount: Double {
        booking.refundAmount
    }
    
    var originalPrice: Double {
        booking.price
    }
    
    var canCancel: Bool {
        booking.canCancel
    }
    
    func cancelBooking() async -> Bool {
        guard canCancel else {
            errorMessage = "Cette réservation ne peut plus être annulée"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Cancel the booking
        let cancelResult = await engine.bookingService.cancelBooking(id: booking.id)
        
        switch cancelResult {
        case .success:
            // Analytics: Booking cancelled
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.bookingCancelled,
                parameters: [
                    "booking_id": booking.id,
                    "status": booking.status.rawValue,
                    "refund_amount": refundAmount
                ]
            )
            
            // Notification de cancellation
            NotificationsManager.shared.notifyBookingCancelled(bookingId: booking.id)
            
            // Pour declined: pas de refund car preauthorized (rien n'a été prélevé)
            // Pour pending/confirmed: refund selon les règles si paymentIntentId existe
            if booking.status != .declined {
                // Seulement pour pending et confirmed, on peut avoir un refund
                if refundAmount > 0, let paymentIntentId = booking.paymentIntentId {
                    let refundResult = await engine.paymentService.refundPayment(paymentIntentId: paymentIntentId)
                    switch refundResult {
                    case .success:
                        // Notification de refund
                        NotificationsManager.shared.notifyRefundProcessed(
                            transactionId: paymentIntentId,
                            amount: refundAmount
                        )
                        return true
                    case .failure(let error):
                        errorMessage = "Réservation annulée mais erreur lors du remboursement: \(error.localizedDescription)"
                        return false
                    }
                }
            }
            // Pour declined ou si pas de paymentIntentId, on retourne juste success
            return true
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }
}

