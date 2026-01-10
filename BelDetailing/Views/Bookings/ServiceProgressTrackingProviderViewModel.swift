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
            let previousProgress = booking.progress?.totalProgress ?? 0
            booking = updatedBooking
            let newProgress = booking.progress?.totalProgress ?? 0
            
            // Notification pour le customer si le progress a changé
            if newProgress > previousProgress, let currentStep = booking.progress?.currentStep {
                NotificationsManager.shared.notifyProgressUpdate(
                    bookingId: booking.id,
                    progress: newProgress,
                    stepName: currentStep.title
                )
                
                // TODO: Si Care Mode activé, envoyer un message automatique
                // Ex: "Interior finished – exterior in progress"
                // await sendCareModeAutoMessage(stepId: currentStep.id, message: "\(currentStep.title) terminé")
            }
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
            
            // Analytics: Service completed
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.serviceCompleted,
                parameters: [
                    "booking_id": booking.id,
                    "provider_id": booking.providerId,
                    "service_name": booking.displayServiceName,
                    "price": booking.price,
                    "currency": booking.currency
                ]
            )
            
            // Notification pour le customer
            NotificationsManager.shared.notifyServiceCompleted(
                bookingId: booking.id,
                serviceName: booking.displayServiceName
            )
        case .failure(let error):
            errorMessage = error.localizedDescription
            FirebaseManager.shared.recordError(error, userInfo: ["booking_id": booking.id])
        }
    }
}

