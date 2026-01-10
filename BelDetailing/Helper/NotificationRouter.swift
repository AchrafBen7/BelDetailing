//
//  NotificationRouter.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import Combine

/// Représente une destination de navigation depuis une notification
enum NotificationDestination: Equatable {
    case booking(id: String)
    case offer(id: String)
    case payment(transactionId: String)
    case profile
    case dashboard
    case none
}

/// Router pour gérer la navigation depuis les notifications
@MainActor
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()
    
    @Published var destination: NotificationDestination? = nil
    
    private init() {}
    
    /// Traite une notification et détermine la destination
    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else {
            print("⚠️ [NotificationRouter] No type in userInfo")
            destination = .none
            return
        }
        
        switch type.lowercased() {
        case "booking", "booking_update", "booking_confirmed", "booking_declined", "booking_started", "booking_completed", "booking_cancelled":
            if let bookingId = userInfo["booking_id"] as? String ?? userInfo["bookingId"] as? String {
                destination = .booking(id: bookingId)
            } else {
                print("⚠️ [NotificationRouter] Booking notification without booking_id")
                destination = .none
            }
            
        case "offer", "offer_application", "application_accepted", "application_refused":
            if let offerId = userInfo["offer_id"] as? String ?? userInfo["offerId"] as? String {
                destination = .offer(id: offerId)
            } else {
                print("⚠️ [NotificationRouter] Offer notification without offer_id")
                destination = .none
            }
            
        case "payment", "payment_succeeded", "payment_failed", "refund":
            if let transactionId = userInfo["transaction_id"] as? String ?? userInfo["transactionId"] as? String {
                destination = .payment(transactionId: transactionId)
            } else {
                print("⚠️ [NotificationRouter] Payment notification without transaction_id")
                destination = .profile // Fallback vers profile pour voir les transactions
            }
            
        case "service_progress", "progress_update":
            if let bookingId = userInfo["booking_id"] as? String ?? userInfo["bookingId"] as? String {
                destination = .booking(id: bookingId)
            } else {
                destination = .none
            }
            
        default:
            print("⚠️ [NotificationRouter] Unknown notification type: \(type)")
            destination = .none
        }
    }
    
    /// Réinitialise la destination (appelé après navigation)
    func reset() {
        destination = nil
    }
}

