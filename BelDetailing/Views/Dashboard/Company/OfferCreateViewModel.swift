//
//  OfferCreateViewModel.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import Combine
@MainActor
final class OfferCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var category: ServiceCategory?
    @Published var vehicleCount: Int = 1
    @Published var priceMin: Double = 100
    @Published var priceMax: Double = 500
    @Published var city: String = ""
    @Published var postalCode: String = ""
    @Published var type: OfferType = .oneTime
    @Published var isLoading = false
    @Published var error: String?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        // Pré-remplir avec les infos de la company si disponibles
        if let companyProfile = engine.userService.fullUser?.companyProfile {
            city = companyProfile.city ?? ""
            postalCode = companyProfile.postalCode ?? ""
        }
    }
    
    var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        category != nil &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        priceMin > 0 &&
        priceMax >= priceMin &&
        vehicleCount > 0
    }
    
    func createOffer() async -> Bool {
        guard let category = category else {
            error = "Veuillez sélectionner une catégorie"
            return false
        }
        
        guard canCreate else {
            error = "Veuillez remplir tous les champs requis"
            return false
        }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let payload: [String: Any] = [
            "title": title.trimmingCharacters(in: .whitespacesAndNewlines),
            "description": description.trimmingCharacters(in: .whitespacesAndNewlines),
            "category": category.rawValue,
            "vehicleCount": vehicleCount,
            "priceMin": priceMin,
            "priceMax": priceMax,
            "city": city.trimmingCharacters(in: .whitespacesAndNewlines),
            "postalCode": postalCode.trimmingCharacters(in: .whitespacesAndNewlines),
            "type": type.rawValue
        ]
        
        let result = await engine.offerService.createOffer(payload)
        
        switch result {
        case .success:
            // Analytics: Offer created
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.offerCreated,
                parameters: [
                    "category": category.rawValue,
                    "vehicle_count": vehicleCount,
                    "price_min": priceMin,
                    "price_max": priceMax,
                    "type": type.rawValue
                ]
            )
            return true
        case .failure(let err):
            error = err.localizedDescription
            FirebaseManager.shared.recordError(err, userInfo: ["action": "create_offer"])
            return false
        }
    }
}

