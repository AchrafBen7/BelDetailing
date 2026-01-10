//
//  ProviderPortfolioService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

protocol ProviderPortfolioService {
    func getPortfolio(providerId: String) async -> APIResponse<[PortfolioPhoto]>
    func addPhoto(imageUrl: String, caption: String?, serviceCategory: ServiceCategory?) async -> APIResponse<PortfolioPhoto>
    func deletePhoto(photoId: String) async -> APIResponse<Bool>
    func updatePhoto(photoId: String, caption: String?, displayOrder: Int) async -> APIResponse<PortfolioPhoto>
}

final class ProviderPortfolioServiceNetwork: ProviderPortfolioService {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getPortfolio(providerId: String) async -> APIResponse<[PortfolioPhoto]> {
        await networkClient.call(endPoint: .providerPortfolio(providerId: providerId))
    }
    
    func addPhoto(imageUrl: String, caption: String?, serviceCategory: ServiceCategory?) async -> APIResponse<PortfolioPhoto> {
        var payload: [String: Any] = [
            "image_url": imageUrl
        ]
        
        if let caption = caption, !caption.isEmpty {
            payload["caption"] = caption
        }
        
        if let category = serviceCategory {
            payload["service_category"] = category.rawValue
        }
        
        return await networkClient.call(
            endPoint: .providerPortfolioAdd,
            dict: payload
        )
    }
    
    func deletePhoto(photoId: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .providerPortfolioDelete(id: photoId)
        )
        
        switch response {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updatePhoto(photoId: String, caption: String?, displayOrder: Int) async -> APIResponse<PortfolioPhoto> {
        var payload: [String: Any] = [:]
        
        if let caption = caption, !caption.isEmpty {
            payload["caption"] = caption
        }
        
        payload["display_order"] = displayOrder
        
        return await networkClient.call(
            endPoint: .providerPortfolioUpdate(id: photoId),
            dict: payload
        )
    }
}
