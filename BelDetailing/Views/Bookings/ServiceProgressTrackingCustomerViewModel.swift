//
//  ServiceProgressTrackingCustomerViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class ServiceProgressTrackingCustomerViewModel: ObservableObject {
    @Published var booking: Booking
    @Published var isLoading = false
    
    let engine: Engine
    
    private var pollingTask: Task<Void, Never>?
    
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
    
    // MARK: - Actions
    
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await load()
                try? await Task.sleep(nanoseconds: 3_000_000_000) // Poll every 3 seconds
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func load() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.bookingService.getBookingDetail(id: booking.id)
        if case .success(let updatedBooking) = result {
            booking = updatedBooking
        }
    }
}

