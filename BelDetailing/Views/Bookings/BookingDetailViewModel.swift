//
//  BookingDetailViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class BookingDetailViewModel: ObservableObject {
    @Published var booking: Booking
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    // MARK: - Computed Properties
    
    var canStartService: Bool {
        booking.status == .confirmed
    }
    
    var isServiceInProgress: Bool {
        booking.status == .started || booking.status == .inProgress
    }
    
    var progressPercentage: Int {
        booking.progress?.totalProgress ?? 0
    }
    
    // MARK: - Actions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.bookingService.getBookingDetail(id: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func startService() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.startService(bookingId: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

