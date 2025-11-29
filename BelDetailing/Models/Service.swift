//
//  Service.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation




/// Een dienst die een detailer aanbiedt (bv. Polissage, Nettoyage intérieur, …)
struct Service: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let name: String              // weergavenaam (kan server-side al gelokaliseerd zijn, of raw + category gebruiken)
    let category: ServiceCategory // gebruik je bestaande enum + localized displayName
    let price: Double             // basisprijs (EUR)
    let durationMinutes: Int      // duur in minuten
    let description: String?
    let isAvailable: Bool
    let imageUrl: String?
    let reservationCount: Int?
}

/// Handige formatter helpers (optioneel)
extension Service {
    var formattedDuration: String { "\(durationMinutes) min" }
    var formattedPrice: String { String(format: "€ %.2f", price) }
    var serviceImageURL: URL? {
        guard let imageUrl,
              let url = URL(string: imageUrl)
        else { return nil }
        return url
    }
}

// MARK: - Samples voor Mock
extension Service {
    static var sampleValues: [Service] {
        [
            Service(
                id: "srv_001",
                providerId: "prov_001",
                name: "Polissage complet",
                category: .carPolishing,
                price: 120.0,
                durationMinutes: 90,
                description: "Restauration de la brillance, micro-rayures atténuées.",
                isAvailable: true,
                imageUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/v1762979544/detail2_bm8svh.jpg",
                reservationCount: 47
                
            ),
            Service(
                id: "srv_002",
                providerId: "prov_001",
                name: "Nettoyage intérieur",
                category: .interiorDetailing,
                price: 80.0,
                durationMinutes: 60,
                description: "Aspiration, plastiques, vitres, traitement tissus.",
                isAvailable: true,
                imageUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/v1762979544/detail2_bm8svh.jpg",
                reservationCount: 23
            ),
            Service(
                id: "srv_003",
                providerId: "prov_002",
                name: "Lavage extérieur",
                category: .carCleaning,
                price: 50.0,
                durationMinutes: 45,
                description: "Prélavage, lavage main, séchage microfibre.",
                isAvailable: true,
                imageUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/v1762979544/detail2_bm8svh.jpg",
                reservationCount: 10
            ),
            Service(
                id: "srv_004",
                providerId: "prov_002",
                name: "Céramique 1 couche",
                category: .ceramicCoating,
                price: 350.0,
                durationMinutes: 240,
                description: "Protection hydrophobe, brillance longue durée.",
                isAvailable: false,
                imageUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/v1762979544/detail2_bm8svh.jpg",
                reservationCount: 67
            )
        ]
    }
}

