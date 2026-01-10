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
    @Published var smartRebookSuggestion: SmartRebookSuggestion?
    
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
            
            // Générer la suggestion Smart Rebook si le booking est complété
            if updatedBooking.status == .completed {
                await generateSmartRebookSuggestion()
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func generateSmartRebookSuggestion() async {
        // Calculer la date suggérée (6 semaines après)
        let (suggestedDate, suggestedStartTime, suggestedEndTime) = SmartRebookSuggestion.calculateSuggestedDate(
            from: booking.date,
            originalStartTime: booking.startTime ?? "00:00"
        )
        
        // Pas de serviceId dans le modèle Booking actuel.
        // On envoie uniquement les noms de service (un seul pour l’instant).
        let serviceIds: [String] = []
        let serviceNames: [String] = [booking.displayServiceName]
        
        // Créer la suggestion
        smartRebookSuggestion = SmartRebookSuggestion(
            id: UUID().uuidString,
            originalBookingId: booking.id,
            providerId: booking.providerId,
            providerName: booking.providerName ?? "Provider",
            serviceIds: serviceIds,
            serviceNames: serviceNames,
            suggestedDate: suggestedDate,
            suggestedStartTime: suggestedStartTime,
            suggestedEndTime: suggestedEndTime,
            address: booking.address,
            totalPrice: booking.price,
            currency: booking.currency,
            message: "Réservez à nouveau le même service dans 6 semaines !"
        )
    }
    
    func startService() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.startService(bookingId: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
            
            // Analytics: Service started
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.serviceStarted,
                parameters: [
                    "booking_id": booking.id,
                    "provider_id": booking.providerId,
                    "service_name": booking.displayServiceName
                ]
            )
            
            // Notification pour le customer
            NotificationsManager.shared.notifyServiceStarted(
                bookingId: booking.id,
                serviceName: booking.displayServiceName
            )
        case .failure(let error):
            errorMessage = error.localizedDescription
            FirebaseManager.shared.recordError(error, userInfo: ["booking_id": booking.id])
        }
    }
    
    func acceptCounterProposal() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.acceptCounterProposal(bookingId: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
            // Notification pour le provider
            NotificationsManager.shared.notifyCounterProposalAccepted(bookingId: booking.id)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func refuseCounterProposal() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.bookingService.refuseCounterProposal(bookingId: booking.id)
        switch result {
        case .success(let updatedBooking):
            booking = updatedBooking
            // Notification pour le provider
            NotificationsManager.shared.notifyCounterProposalRefused(bookingId: booking.id)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

