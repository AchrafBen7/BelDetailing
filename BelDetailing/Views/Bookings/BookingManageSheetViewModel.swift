//
//  BookingManageSheetViewModel.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import Combine

@MainActor
final class BookingManageSheetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let booking: Booking
    private let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func updateBooking(date: Date, time: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let dateString = DateFormatters.onlyDate(date)
        
        let data: [String: Any] = [
            "date": dateString,
            "startTime": time
        ]
        
        let result = await engine.bookingService.updateBooking(id: booking.id, data: data)
        
        switch result {
        case .success:
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }
}

