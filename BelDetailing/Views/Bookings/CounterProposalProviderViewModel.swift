//
//  CounterProposalProviderViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import Combine
@MainActor
final class CounterProposalProviderViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let booking: Booking
    private let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func sendCounterProposal(date: String, startTime: String, endTime: String, message: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.counterPropose(
            bookingId: booking.id,
            date: date,
            startTime: startTime,
            endTime: endTime,
            message: message
        )
        
        switch result {
        case .success:
            NotificationsManager.shared.notifyCounterProposalSent(bookingId: booking.id)
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }
}

