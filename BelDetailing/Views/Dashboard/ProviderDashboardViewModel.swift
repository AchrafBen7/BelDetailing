//
//  ProviderDashboardViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import Combine

@MainActor
final class ProviderDashboardViewModel: ObservableObject {

    @Published var selectedFilter: ProviderDashboardFilter = .offers
    @Published var services: [Service] = []
    @Published var isLoading = true

    let engine: Engine
    private let providerId = "prov_001"  // plus tard depuis StorageManager

    init(engine: Engine) {
        self.engine = engine
        loadServices()
    }

    func loadServices() {
        Task {
            isLoading = true
            let response = await engine.detailerService.getServices(id: providerId)
            switch response {
            case .success(let list):
                services = list
            case .failure:
                services = []
            }
            isLoading = false
        }
    }

    func deleteService(id: String) {
        //TODO: delete endpoint → pour l’instant mock
        services.removeAll { $0.id == id }
    }
}

enum ProviderDashboardFilter {
    case offers, calendar, stats, reviews
}
