//
//  ServiceProgressTrackingProviderViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class ServiceProgressTrackingProviderViewModel: ObservableObject {
    @Published var booking: Booking
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    // MARK: - Computed Properties
    
    var steps: [ServiceStep] {
        booking.progress?.steps ?? ServiceStep.defaultSteps()
    }
    
    var currentStep: ServiceStep? {
        booking.progress?.currentStep
    }
    
    var progressPercentage: Int {
        booking.progress?.totalProgress ?? 0
    }
    
    var isAllStepsCompleted: Bool {
        booking.progress?.isAllStepsCompleted ?? false
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
    
    func completeStep(stepId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.updateProgress(bookingId: booking.id, stepId: stepId)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func completeService() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.completeService(bookingId: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

