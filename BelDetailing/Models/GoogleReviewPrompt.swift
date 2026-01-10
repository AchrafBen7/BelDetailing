//
//  GoogleReviewPrompt.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

// MARK: - Google Review Prompt Model

struct GoogleReviewPrompt: Codable, Identifiable {
    let id: String
    let bookingId: String
    let customerId: String
    let providerId: String
    let googlePlaceId: String?
    let ratingSelected: Int?
    let promptedAt: String?
    let googleRedirectedAt: String?
    let dismissedAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookingId = "booking_id"
        case customerId = "customer_id"
        case providerId = "provider_id"
        case googlePlaceId = "google_place_id"
        case ratingSelected = "rating_selected"
        case promptedAt = "prompted_at"
        case googleRedirectedAt = "google_redirected_at"
        case dismissedAt = "dismissed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Create Review Prompt Request

struct CreateReviewPromptRequest: Codable {
    let bookingId: String
    
    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
    }
}

// MARK: - Track Rating Request

struct TrackRatingRequest: Codable {
    let rating: Int
}

// MARK: - Google Redirect Response

struct GoogleRedirectResponse: Codable {
    let success: Bool
    let googlePlaceId: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case googlePlaceId = "google_place_id"
    }
}

