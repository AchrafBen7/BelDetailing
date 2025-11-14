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
    let minPrice: Double
    let hasMobileService: Bool
    let logoUrl: String?
    let bannerUrl: String?
    let serviceCategories: [ServiceCategory]

    // ✅ Nouveaux champs
    let teamSize: Int            // nombre de membres (1 = solo)
    let yearsOfExperience: Int   // ex: 5 ans
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
