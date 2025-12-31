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

    enum CodingKeys: String, CodingKey {
        case id
        case providerId        = "provider_id"
        case name
        case category
        case price
        case durationMinutes   = "duration_minutes"
        case description
        case isAvailable       = "is_available"
        case imageUrl          = "image_url"
        case reservationCount  = "reservation_count"
    }

    init(
        id: String,
        providerId: String,
        name: String,
        category: ServiceCategory,
        price: Double,
        durationMinutes: Int,
        description: String?,
        isAvailable: Bool,
        imageUrl: String?,
        reservationCount: Int?
    ) {
        self.id = id
        self.providerId = providerId
        self.name = name
        self.category = category
        self.price = price
        self.durationMinutes = durationMinutes
        self.description = description
        self.isAvailable = isAvailable
        self.imageUrl = imageUrl
        self.reservationCount = reservationCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        providerId = (try? container.decode(String.self, forKey: .providerId)) ?? ""

        name = (try? container.decode(String.self, forKey: .name)) ?? ""

        // category: backend envoie des tokens alignés à ServiceCategory.rawValue (ex: "polishing")
        category = (try? container.decode(ServiceCategory.self, forKey: .category)) ?? .carCleaning

        // price: number ou string possible (on tolère)
        if let priceNumber = try? container.decode(Double.self, forKey: .price) {
            price = priceNumber
        } else if let priceString = try? container.decode(String.self, forKey: .price),
                  let priceValue = Double(priceString) {
            price = priceValue
        } else {
            price = 0
        }

        // durationMinutes: int ou string
        if let durationNumber = try? container.decode(Int.self, forKey: .durationMinutes) {
            durationMinutes = durationNumber
        } else if let durationString = try? container.decode(String.self, forKey: .durationMinutes),
                  let durationValue = Int(durationString) {
            durationMinutes = durationValue
        } else {
            durationMinutes = 0
        }

        // description: string ou null/"<null>"
        if let descRaw = try? container.decode(String.self, forKey: .description) {
            let trimmed = descRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            description = trimmed.isEmpty || trimmed == "<null>" ? nil : trimmed
        } else {
            description = nil
        }

        // isAvailable: bool ou int(0/1) ou string "1"/"true"
        if let availableBool = try? container.decode(Bool.self, forKey: .isAvailable) {
            isAvailable = availableBool
        } else if let availableInt = try? container.decode(Int.self, forKey: .isAvailable) {
            isAvailable = (availableInt == 1)
        } else if let availableString = try? container.decode(String.self, forKey: .isAvailable) {
            isAvailable = (availableString == "1" || availableString.lowercased() == "true")
        } else {
            isAvailable = true
        }

        // imageUrl: string ou "<null>"
        if let imageRaw = try? container.decode(String.self, forKey: .imageUrl) {
            let trimmed = imageRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            imageUrl = trimmed.isEmpty || trimmed == "<null>" ? nil : trimmed
        } else {
            imageUrl = nil
        }

        // reservationCount: int ou string ou null
        if let resCountNumber = try? container.decode(Int.self, forKey: .reservationCount) {
            reservationCount = resCountNumber
        } else if let resCountString = try? container.decode(String.self, forKey: .reservationCount),
                  let resCountValue = Int(resCountString) {
            reservationCount = resCountValue
        } else {
            reservationCount = nil
        }
    }
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
