//
//  VehicleProfileViewModel.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import Foundation
import Combine

@MainActor
final class VehicleProfileViewModel: ObservableObject {
    @Published var vehicleProfile: VehicleProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let customerId: String
    private let vehicleType: VehicleType
    private let engine: Engine
    
    init(customerId: String, vehicleType: VehicleType, engine: Engine) {
        self.customerId = customerId
        self.vehicleType = vehicleType
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Charger les bookings du customer
        let bookingsResult = await engine.bookingService.getBookings(scope: "customer", status: nil)
        
        switch bookingsResult {
        case .success(let bookings):
            // Créer le VehicleProfile depuis les bookings
            vehicleProfile = VehicleProfile.from(
                customerId: customerId,
                vehicleType: vehicleType,
                bookings: bookings
            )
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

