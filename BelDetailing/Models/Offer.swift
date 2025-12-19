//
//  Offer.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//
import Foundation


struct Offer: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let category: ServiceCategory
    let description: String
    let vehicleCount: Int
    let priceMin: Double
    let priceMax: Double
    let city: String
    let postalCode: String
    let lat: Double?
    let lng: Double?
    let type: OfferType
    let status: OfferStatus
    let contractId: String?
    let createdAt: String
    let createdBy: String

    // 👇 depuis la view Supabase
    let companyName: String?
    let companyLogoUrl: String?
    let applicationsCount: Int?   // ⬅️ C’EST CELUI-CI
}


enum OfferStatus: String, Codable, CaseIterable {
    case open
    case closed
    case archived
}


/// ✅ Nieuw
enum OfferType: String, Codable, CaseIterable {
    case oneTime        // Offre ponctuelle
    case recurring      // Récurrente (ex: mensuel)
    case longTerm       // Contrat long terme
}

/// ✅ Nieuw – lichtgewicht attachment model
struct Attachment: Codable, Hashable {
    let id: String
    let fileName: String
    let url: String
    let mimeType: String?      // "application/pdf", "image/jpeg", …
    let sizeBytes: Int?        // optioneel, handig voor UI
}

