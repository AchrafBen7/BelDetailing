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

    // ✅ Nieuw
    let type: OfferType                     // ponctuelle / récurrente / contrat long terme
    let attachments: [Attachment]?          // bestanden gelinkt aan de offer (PDF, images, …)

    let status: OfferStatus
    let contractId: String?
    let createdAt: String
    let createdBy: String

    // Optioneel: inline of “lazy” geladen
    let applications: [Application]?
}

enum OfferStatus: String, Codable {
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

extension Offer {
    static var sampleValues: [Offer] {
        [
            Offer(
                id: "off_001",
                title: "Nettoyage flotte de 50 véhicules",
                category: .carCleaning,
                description: "Garage à Bruxelles cherche prestataire pour entretien mensuel d'une flotte de 50 véhicules.",
                vehicleCount: 50,
                priceMin: 1000,
                priceMax: 2500,
                city: "Bruxelles",
                postalCode: "1000",
                lat: 50.8503,
                lng: 4.3517,
                type: .recurring, // ✅
                attachments: [
                    Attachment(
                        id: "att_001",
                        fileName: "Brief-technique.pdf",
                        url: "https://cdn.example.com/briefs/att_001.pdf",
                        mimeType: "application/pdf",
                        sizeBytes: 284_000
                    ),
                    Attachment(
                        id: "att_002",
                        fileName: "Exemple_finition.jpg",
                        url: "https://cdn.example.com/images/att_002.jpg",
                        mimeType: "image/jpeg",
                        sizeBytes: 512_000
                    )
                ],
                status: .open,
                contractId: "ctr_101",
                createdAt: "2025-11-07T10:00:00Z",
                createdBy: "usr_001",
                applications: Application.sampleValues
            )
        ]
    }
}
