//
//  ProviderPortfolioViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import Combine
@MainActor
final class ProviderPortfolioViewModel: ObservableObject {
    @Published var photos: [PortfolioPhoto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let providerId: String
    private let engine: Engine
    
    init(providerId: String, engine: Engine) {
        self.providerId = providerId
        self.engine = engine
    }
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        
        let result = await engine.providerPortfolioService.getPortfolio(providerId: providerId)
        
        switch result {
        case .success(let portfolioPhotos):
            photos = portfolioPhotos
        case .failure(let error):
            errorMessage = error.localizedDescription
            photos = []
        }
        
        isLoading = false
    }
    
    func deletePhoto(photoId: String) async {
        let result = await engine.providerPortfolioService.deletePhoto(photoId: photoId)
        
        switch result {
        case .success:
            await loadPhotos()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

