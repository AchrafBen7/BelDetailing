//
//  GoogleReviewPromptViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import SwiftUI
import Combine
@MainActor
final class GoogleReviewPromptViewModel: ObservableObject {
    @Published var prompt: GoogleReviewPrompt?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let booking: Booking
    private let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func loadOrCreatePrompt() async {
        isLoading = true
        defer { isLoading = false }
        
        // Essayer de charger un prompt existant
        let existingResponse = await engine.googleReviewService.getPrompt(bookingId: booking.id)
        
        switch existingResponse {
        case .success(let existingPrompt):
            prompt = existingPrompt
            return
        case .failure:
            // Si pas de prompt, en créer un nouveau
            break
        }
        
        // Créer un nouveau prompt
        let createResponse = await engine.googleReviewService.createPrompt(bookingId: booking.id)
        
        switch createResponse {
        case .success(let newPrompt):
            prompt = newPrompt
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func sendRatingAndRedirect(rating: Int) async {
        guard let promptId = prompt?.id else { return }
        
        // 1. Enregistrer la note (stats internes)
        _ = await engine.googleReviewService.trackRating(promptId: promptId, rating: rating)
        
        // 2. Si 4+ étoiles, rediriger vers Google
        if rating >= 4 {
            await redirectToGoogle(promptId: promptId)
        }
    }
    
    func redirectToGoogle(promptId: String) async {
        let response = await engine.googleReviewService.trackGoogleRedirect(promptId: promptId)
        
        switch response {
        case .success(let redirectResponse):
            if let placeId = redirectResponse.googlePlaceId {
                openGoogleReview(placeId: placeId)
            } else {
                // Fallback : ouvrir Google Maps avec le nom du provider
                openGoogleMapsFallback()
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            // Ouvrir quand même Google Maps en fallback
            openGoogleMapsFallback()
        }
    }
    
    private func openGoogleReview(placeId: String) {
        // Deep link Google Review avec Place ID
        let urlString = "https://search.google.com/local/writereview?placeid=\(placeId)"
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback : ouvrir dans Safari
                openGoogleMapsFallback()
            }
        }
    }
    
    private func openGoogleMapsFallback() {
        // Fallback : ouvrir Google Maps avec le nom du provider
        if let providerName = booking.providerName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "https://www.google.com/maps/search/?api=1&query=\(providerName)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func dismissPrompt() async {
        guard let promptId = prompt?.id else { return }
        _ = await engine.googleReviewService.dismissPrompt(promptId: promptId)
    }
}

