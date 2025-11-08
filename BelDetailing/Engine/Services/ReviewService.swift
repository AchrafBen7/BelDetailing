//
//  ReviewService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Protocol
protocol ReviewService {
    /// Liste des avis pour un prestataire
    func getReviews(providerId: String) async -> APIResponse<[Review]>
    /// Crée un nouvel avis (après une réservation)
    func createReview(_ data: [String: Any]) async -> APIResponse<Review>
}

// MARK: - Network
final class ReviewServiceNetwork: ReviewService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getReviews(providerId: String) async -> APIResponse<[Review]> {
        await networkClient.call(endPoint: .providerReviews(providerId: providerId))
    }

    func createReview(_ data: [String: Any]) async -> APIResponse<Review> {   
        // Payload attendu : { providerId, bookingId?, rating, comment }
        await networkClient.call(endPoint: .providerReviewCreate, dict: data)
    }
}

// MARK: - Mock
final class ReviewServiceMock: MockService, ReviewService {
    func getReviews(providerId: String) async -> APIResponse<[Review]> {
        await randomWait()
        let items = Review.sampleValues.filter { $0.providerId == providerId }
        return .success(items)
    }

    func createReview(_ data: [String: Any]) async -> APIResponse<Review> {
        await randomWait()
        // Echo du premier sample (mock)
        return .success(Review.sampleValues.first!)
    }
}
