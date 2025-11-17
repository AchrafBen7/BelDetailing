//
//  DetailerDetailViewModel.swift
//  BelDetailing
//

import SwiftUI
import Combine

@MainActor
final class DetailerDetailViewModel: ObservableObject {

    @Published var detailer: Detailer?
    @Published var services: [Service] = []

    @Published var isLoading = true
    @Published var isLoadingServices = true
    @Published var errorText: String?
    
    @Published var reviews: [Review] = []
    @Published var isLoadingReviews = false

    let id: String
    let engine: Engine

    init(id: String, engine: Engine) {
        self.id = id
        self.engine = engine
        Task { await load() }
    }

    // MARK: LOAD MAIN PROFILE
    func load() async {
        isLoading = true

        let response = await engine.detailerService.getProfile(id: id)

        switch response {
        case .success(let provider):
            self.detailer = provider
        case .failure(let err):
            self.errorText = err.localizedDescription
        }

        isLoading = false

        // Load services AFTER profile
        await loadServices()
        await loadReviews()

    }

    // MARK: LOAD SERVICES
    func loadServices() async {
        isLoadingServices = true

        let response = await engine.detailerService.getServices(id: id)

        switch response {
        case .success(let list):
            self.services = list
        case .failure:
            self.services = []
        }

        isLoadingServices = false
    }
    
    func loadReviews() async {
        isLoadingReviews = true

        let response = await engine.reviewService.getReviews(providerId: id)

        switch response {
        case .success(let list):
            self.reviews = list
        case .failure:
            self.reviews = []
        }

        isLoadingReviews = false
    }

}
