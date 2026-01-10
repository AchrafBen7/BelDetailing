//
//  GoogleReviewService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

// MARK: - GoogleReviewService Protocol

protocol GoogleReviewService {
    func createPrompt(bookingId: String) async -> APIResponse<GoogleReviewPrompt>
    func getPrompt(bookingId: String) async -> APIResponse<GoogleReviewPrompt>
    func trackRating(promptId: String, rating: Int) async -> APIResponse<Bool>
    func trackGoogleRedirect(promptId: String) async -> APIResponse<GoogleRedirectResponse>
    func dismissPrompt(promptId: String) async -> APIResponse<Bool>
}

// MARK: - Network Implementation

final class GoogleReviewServiceNetwork: GoogleReviewService {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func createPrompt(bookingId: String) async -> APIResponse<GoogleReviewPrompt> {
        let payload: [String: Any] = [
            "booking_id": bookingId
        ]
        
        return await networkClient.call(
            endPoint: .reviewPromptCreate,
            dict: payload
        )
    }
    
    func getPrompt(bookingId: String) async -> APIResponse<GoogleReviewPrompt> {
        await networkClient.call(endPoint: .reviewPromptGet(bookingId: bookingId))
    }
    
    func trackRating(promptId: String, rating: Int) async -> APIResponse<Bool> {
        let payload: [String: Any] = [
            "rating": rating
        ]
        
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .reviewPromptTrackRating(id: promptId),
            dict: payload
        )
        
        switch response {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func trackGoogleRedirect(promptId: String) async -> APIResponse<GoogleRedirectResponse> {
        let response: APIResponse<GoogleRedirectResponse> = await networkClient.call(
            endPoint: .reviewPromptGoogleRedirect(id: promptId)
        )
        return response
    }
    
    func dismissPrompt(promptId: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .reviewPromptDismiss(id: promptId)
        )
        
        switch response {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
}

