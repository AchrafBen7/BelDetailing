//
//  ProviderServiceDTO.swift
//  BelDetailing
//
//  Created by Achraf Benali on 26/12/2025.
//

import Foundation

// DTO aligné 1:1 avec la réponse backend pour /providers/.../services
// Décodage tolérant: is_available peut être 0/1 (Int) ou true/false (Bool) ou String.
struct ProviderServiceDTO: Decodable {
    let id: String
    let providerId: String
    let name: String
    let category: String
    let price: Double
    let durationMinutes: Int
    let description: String?
    let imageUrl: String?
    let reservationCount: Int?

    // Propriété normalisée
    let isAvailableBool: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case providerId
        case name
        case category
        case price
        case durationMinutes
        case description
        case imageUrl
        case reservationCount
        case isAvailable // convertFromSnakeCase prendra "is_available"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        providerId = try container.decode(String.self, forKey: .providerId)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        price = try container.decode(Double.self, forKey: .price)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        description = try? container.decode(String.self, forKey: .description)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        reservationCount = try? container.decode(Int.self, forKey: .reservationCount)

        // Décodage tolérant de is_available
        if let boolVal = try? container.decode(Bool.self, forKey: .isAvailable) {
            isAvailableBool = boolVal
            print("ℹ️ [DTO] is_available decoded as Bool:", boolVal)
        } else if let intVal = try? container.decode(Int.self, forKey: .isAvailable) {
            isAvailableBool = intVal != 0
            print("ℹ️ [DTO] is_available decoded as Int:", intVal, "->", isAvailableBool)
        } else if let strVal = try? container.decode(String.self, forKey: .isAvailable) {
            let lower = strVal.lowercased()
            isAvailableBool = (lower == "true" || lower == "1")
            print("ℹ️ [DTO] is_available decoded as String:", strVal, "->", isAvailableBool)
        } else {
            isAvailableBool = false
            print("⚠️ [DTO] is_available missing/invalid, defaulting to false")
        }
    }
}

// MARK: - Mapping vers le domain model Service
extension ProviderServiceDTO {
    func toDomain() -> Service? {
        guard let cat = ServiceCategory(apiValue: category) else {
            return nil
        }

        return Service(
            id: id,
            providerId: providerId,
            name: name,
            category: cat,
            price: price,
            durationMinutes: durationMinutes,
            description: description,
            isAvailable: isAvailableBool,
            imageUrl: imageUrl,
            reservationCount: reservationCount
        )
    }
}

// MARK: - Helper tolérant pour mapper les valeurs API -> ServiceCategory
extension ServiceCategory {
    init?(apiValue: String) {
        let value = apiValue.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔎 [Category] mapping apiValue='\(value)'")

        switch value {
        case "interior", "interiorDetailing":
            self = .interiorDetailing
        case "exterior", "exteriorDetailing":
            self = .exteriorDetailing
        case "full", "carCleaning", "cleaning":
            self = .carCleaning
        case "polishing", "carPolishing":
            self = .carPolishing
        case "ceramic", "ceramicCoating":
            self = .ceramicCoating
        case "paint_correction", "paintCorrection":
            self = .paintCorrection
        case "headlight", "headlightRestoration":
            self = .headlightRestoration
        case "engine_bay", "engineBay":
            self = .engineBay
        case "wheels_tires", "wheelsTires":
            self = .wheelsTires
        case "wax_sealant", "waxSealant":
            self = .waxSealant
        default:
            print("⚠️ [Category] unknown apiValue: \(value)")
            return nil
        }

        print("✅ [Category] mapped to case: \(self)")
    }
}

