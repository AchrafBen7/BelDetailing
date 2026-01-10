//
//  ProviderCreateServiceViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 25/12/2025.
//
import Foundation
import Combine
@MainActor
final class ProviderCreateServiceViewModel: ObservableObject {

    @Published var name = ""
    @Published var description = ""
    @Published var category: ServiceCategory?
    @Published var price: Double = 60
    @Published var durationMinutes: Int = 60
    @Published var isLoading = false
    @Published var error: String?

    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }

    func createService() async -> Bool {
        guard let category else {
            error = "Veuillez choisir une catégorie"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        let payload: [String: Any?] = [
            "name": name,
            "description": description,
            "category": category.rawValue,
            "price": price,
            "duration_minutes": durationMinutes,
            "is_available": true
        ]

        let res = await engine.detailerService.createMyService(data: payload)

        switch res {
        case .success:
            // Analytics: Provider service created
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.providerServiceCreated,
                parameters: [
                    "category": category.rawValue,
                    "price": price,
                    "duration_minutes": durationMinutes
                ]
            )
            return true
        case .failure(let err):
            error = err.localizedDescription
            FirebaseManager.shared.recordError(err, userInfo: ["action": "create_service"])
            return false
        }
    }
}
