//
//  CreateReviewViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import Combine

@MainActor
final class CreateReviewViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let booking: Booking
    let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func createReview(rating: Int, comment: String?) async -> Bool {
        guard rating >= 1 && rating <= 5 else {
            errorMessage = "Veuillez sélectionner une note entre 1 et 5 étoiles"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Préparer le payload
        var payload: [String: Any] = [
            "providerId": booking.providerId,
            "rating": rating
        ]
        
        // Ajouter bookingId si disponible
        if !booking.id.isEmpty {
            payload["bookingId"] = booking.id
        }
        
        // Ajouter commentaire si fourni
        if let comment = comment, !comment.isEmpty {
            payload["comment"] = comment
        }
        
        let result = await engine.reviewService.createReview(payload)
        
        switch result {
        case .success:
            // Analytics: Review submitted
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.reviewSubmitted,
                parameters: [
                    "booking_id": booking.id,
                    "provider_id": booking.providerId,
                    "rating": rating
                ]
            )
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            FirebaseManager.shared.recordError(error, userInfo: ["booking_id": booking.id])
            return false
        }
    }
}

