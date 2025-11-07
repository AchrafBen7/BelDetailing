//
//  ReviewService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//


import Foundation

// MARK: - Protocol
protocol ReviewService {
    /// Lijst van reviews voor een prestataire
    func getReviews(providerId: String) async -> APIResponse<[Review>]
    /// Nieuwe review posten (na een booking)
    func createReview(_ data: [String: Any]) async -> APIResponse<Review>
}

// MARK: - Network
final class ReviewServiceNetwork: ReviewService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getReviews(providerId: String) async -> APIResponse<[Review]> {
        await networkClient.call(endPoint: .providerReviews(providerId: providerId))
    }

    func createReview(_ data: [String: Any]) async -> APIResponse[Review] {
        // Verwacht payload: { providerId, bookingId?, rating, comment }
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
        // Echo naar eerste sample (mock)
        return .success(Review.sampleValues.first!)
    }
}
