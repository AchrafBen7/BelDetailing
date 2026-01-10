//
//  CareModeStepPhoto.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import Foundation

/// Photo intermédiaire prise pendant un step (NIOS Care Mode)
struct CareModeStepPhoto: Codable, Identifiable {
    let id: String
    let stepId: String
    let bookingId: String
    let photoUrl: String
    let thumbnailUrl: String
    let caption: String? // Légende optionnelle
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case stepId = "step_id"
        case bookingId = "booking_id"
        case photoUrl = "photo_url"
        case thumbnailUrl = "thumbnail_url"
        case caption
        case createdAt = "created_at"
    }
}

/// Message automatique envoyé lors d'un step (NIOS Care Mode)
struct CareModeAutoMessage: Codable, Identifiable {
    let id: String
    let bookingId: String
    let stepId: String
    let message: String
    let sentAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookingId = "booking_id"
        case stepId = "step_id"
        case message
        case sentAt = "sent_at"
    }
}

/// Extension de ServiceStep pour supporter les photos (Care Mode)
extension ServiceStep {
    var photos: [CareModeStepPhoto]? {
        // Les photos seront chargées séparément depuis le backend
        nil
    }
}

