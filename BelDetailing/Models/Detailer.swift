//
//  Detailer.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

struct Detailer: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    let companyName: String?
    let bio: String?
    let city: String
    let postalCode: String
    let lat: Double
    let lng: Double
    let rating: Double
    let reviewCount: Int
    let minPrice: Double?                 // ⬅️ optional (backend can return null)
    let hasMobileService: Bool
    let logoUrl: String?
    let bannerUrl: String?
    let serviceCategories: [ServiceCategory]
    let phone: String?
    let email: String?
    let openingHours: String?

    // ✅ Nouveaux champs
    let teamSize: Int            // nombre de membres (1 = solo)
    let yearsOfExperience: Int   // ex: 5 ans
}

// MARK: - Safe decoding to handle rating as number or string, minPrice as number or null
extension Detailer {
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case companyName
        case bio
        case city
        case postalCode
        case lat
        case lng
        case rating
        case reviewCount
        case minPrice
        case hasMobileService
        case logoUrl
        case bannerUrl
        case serviceCategories
        case phone
        case email
        case openingHours
        case teamSize
        case yearsOfExperience
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        companyName = try? container.decode(String.self, forKey: .companyName)
        bio = try? container.decode(String.self, forKey: .bio)
        city = (try? container.decode(String.self, forKey: .city)) ?? ""

        // postalCode can be number or string in payload; decode safely to String
        if let postalInt = try? container.decode(Int.self, forKey: .postalCode) {
            postalCode = String(postalInt)
        } else {
            postalCode = (try? container.decode(String.self, forKey: .postalCode)) ?? ""
        }

        // lat/lng sometimes arrive as strings in logs; decode flexibly
        if let latitudeNumber = try? container.decode(Double.self, forKey: .lat) {
            lat = latitudeNumber
        } else if let latitudeString = try? container.decode(String.self, forKey: .lat),
                  let latitude = Double(latitudeString) {
            lat = latitude
        } else {
            lat = 0
        }

        if let longitudeNumber = try? container.decode(Double.self, forKey: .lng) {
            lng = longitudeNumber
        } else if let longitudeString = try? container.decode(String.self, forKey: .lng),
                  let longitude = Double(longitudeString) {
            lng = longitude
        } else {
            lng = 0
        }

        // rating sometimes string ("4.8") or number
        if let ratingNumber = try? container.decode(Double.self, forKey: .rating) {
            rating = ratingNumber
        } else if let ratingString = try? container.decode(String.self, forKey: .rating),
                  let ratingValue = Double(ratingString) {
            rating = ratingValue
        } else {
            rating = 0
        }

        reviewCount = (try? container.decode(Int.self, forKey: .reviewCount)) ?? 0

        // minPrice can be number or null
        if let minPriceNumber = try? container.decode(Double.self, forKey: .minPrice) {
            minPrice = minPriceNumber
        } else if let minPriceString = try? container.decode(String.self, forKey: .minPrice),
                  let minPriceValue = Double(minPriceString) {
            minPrice = minPriceValue
        } else if (try? container.decodeNil(forKey: .minPrice)) == true {
            minPrice = nil
        } else {
            minPrice = nil
        }

        hasMobileService = (try? container.decode(Bool.self, forKey: .hasMobileService)) ?? false
        logoUrl = try? container.decode(String.self, forKey: .logoUrl)
        bannerUrl = try? container.decode(String.self, forKey: .bannerUrl)
        phone = try? container.decode(String.self, forKey: .phone)
        email = try? container.decode(String.self, forKey: .email)
        openingHours = try? container.decode(String.self, forKey: .openingHours)

        teamSize = (try? container.decode(Int.self, forKey: .teamSize)) ?? 1
        yearsOfExperience = (try? container.decode(Int.self, forKey: .yearsOfExperience)) ?? 0

        // Decode categories directly (ServiceCategory raw values are backend-aligned)
        serviceCategories = (try? container.decode([ServiceCategory].self, forKey: .serviceCategories)) ?? []
    }
}

// MARK: - Convenience computed values
extension Detailer {
    /// Fallback for display/sorting when minPrice is null
    var minPriceValue: Double { minPrice ?? 0 }
}

extension Detailer {
    /// 🧠 Texte localisable selon la taille d’équipe
    var teamDescriptionKey: String {
        switch teamSize {
        case 0, 1: return "detailer.team.solo"
        case 2...4: return "detailer.team.small"
        case 5...10: return "detailer.team.medium"
        default: return "detailer.team.large"
        }
    }

    /// Exemple de traduction directe (si R.swift est intégré)
    var teamDescription: String {
        NSLocalizedString(teamDescriptionKey, comment: "")
    }
}

extension Detailer {
    static var sampleValues: [Detailer] {
        [
            Detailer(
                id: "prov_001",
                displayName: "Clean & Shine",
                companyName: "Clean & Shine SPRL",
                bio: "Experts du detailing automobile haut de gamme à Bruxelles.",
                city: "Bruxelles",
                postalCode: "1000",
                lat: 50.8503,
                lng: 4.3517,
                rating: 4.8,
                reviewCount: 120,
                minPrice: 80,
                hasMobileService: true,
                logoUrl: "https://cdn.example.com/providers/prov_001_logo.jpg",
                bannerUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/v1762979544/detail2_bm8svh.jpg",
                serviceCategories: [.carCleaning, .carPolishing, .interiorDetailing],
                phone: "+32 477 12 34 56",
                email: "contact@cleanandshine.be",
                openingHours: "Mon–Sat: 9h–18h",
                teamSize: 3,
                yearsOfExperience: 7
            ),
            Detailer(
                id: "prov_002",
                displayName: "AutoClean Expert",
                companyName: "AutoClean SRL",
                bio: "Service rapide et professionnel, nettoyage intérieur/extérieur.",
                city: "Ixelles",
                postalCode: "1050",
                lat: 50.833,
                lng: 4.366,
                rating: 4.5,
                reviewCount: 75,
                minPrice: 60,
                hasMobileService: false,
                logoUrl: nil,
                bannerUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png",
                serviceCategories: [.carCleaning, .ceramicCoating],
                phone: "+32 477 12 34 56",
                email: "contact@cleanandshine.be",
                openingHours: "Mon–Sat: 9h–18h",
                teamSize: 1,
                yearsOfExperience: 4
            ),
            Detailer(
                id: "prov_003",
                displayName: "AutoClean Expert",
                companyName: "AutoClean SRL",
                bio: "Service rapide et professionnel, nettoyage intérieur/extérieur.",
                city: "Ixelles",
                postalCode: "1050",
                lat: 50.833,
                lng: 4.366,
                rating: 4.5,
                reviewCount: 75,
                minPrice: 60,
                hasMobileService: false,
                logoUrl: nil,
                bannerUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png",
                serviceCategories: [.carCleaning, .ceramicCoating],
                phone: "+32 477 12 34 56",
                email: "contact@cleanandshine.be",
                openingHours: "Mon–Sat: 9h–18h",
                teamSize: 1,
                yearsOfExperience: 4
            ),
            Detailer(
                id: "prov_004",
                displayName: "AutoClean Expert",
                companyName: "AutoClean SRL",
                bio: "Service rapide et professionnel, nettoyage intérieur/extérieur.",
                city: "Ixelles",
                postalCode: "1050",
                lat: 50.833,
                lng: 4.366,
                rating: 4.5,
                reviewCount: 75,
                minPrice: 60,
                hasMobileService: false,
                logoUrl: nil,
                bannerUrl: "https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png",
                serviceCategories: [.carCleaning, .ceramicCoating],
                phone: "+32 477 12 34 56",
                email: "contact@cleanandshine.be",
                openingHours: "Mon–Sat: 9h–18h",
                teamSize: 1,
                yearsOfExperience: 4
            )
        ]
    }
}

extension Detailer {
  /// En attendant la vraie durée depuis l'API
  var mockDurationText: String { "2–3h" }

  /// En attendant la vraie distance (ne mettre que la valeur, l’unité vient du Localizable)
  var mockDistanceKmText: String { "2.3" }
}

// MARK: - URL Helpers
extension Detailer {
    var bannerURL: URL? {
        guard let urlString = bannerUrl else { return nil }
        return URL(string: urlString)
    }

    var logoURL: URL? {
        guard let urlString = logoUrl else { return nil }
        return URL(string: urlString)
    }
}
