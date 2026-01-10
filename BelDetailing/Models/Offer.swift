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
    let applicationsCount: Int?   // ⬅️ C'EST CELUI-CI
    
    // MARK: - Custom Decoding (tolerant)
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case description
        case vehicleCount
        case priceMin
        case priceMax
        case city
        case postalCode
        case lat
        case lng
        case type
        case status
        case contractId
        case createdAt
        case createdBy
        case companyName
        case companyLogoUrl
        case applicationsCount
        case applications // Backend might send "applications" instead of "applicationsCount"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id          = try container.decode(String.self, forKey: .id)
        title       = try container.decode(String.self, forKey: .title)
        category    = Self.decodeCategory(from: container)
        description = try container.decode(String.self, forKey: .description)
        
        vehicleCount = Self.decodeIntOrString(container, key: .vehicleCount) ?? 1
        priceMin     = Self.decodeDoubleIntOrString(container, key: .priceMin) ?? 0.0
        priceMax     = Self.decodeDoubleIntOrString(container, key: .priceMax) ?? 0.0
        
        city       = try container.decode(String.self, forKey: .city)
        postalCode = Self.decodePostalCode(container) ?? ""
        
        lat = Self.decodeDoubleOrString(container, key: .lat)
        lng = Self.decodeDoubleOrString(container, key: .lng)
        
        type       = try container.decode(OfferType.self, forKey: .type)
        status     = try container.decode(OfferStatus.self, forKey: .status)
        contractId = try? container.decode(String.self, forKey: .contractId)
        createdAt  = try container.decode(String.self, forKey: .createdAt)
        createdBy  = try container.decode(String.self, forKey: .createdBy)
        
        companyName    = Self.decodeOptionalNonNullString(container, key: .companyName)
        companyLogoUrl = Self.decodeOptionalNonNullString(container, key: .companyLogoUrl)
        applicationsCount = Self.decodeApplicationsCount(container)
    }
    
    // MARK: - Custom Encoding (ensure Encodable conformance)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(category, forKey: .category)
        try container.encode(description, forKey: .description)
        try container.encode(vehicleCount, forKey: .vehicleCount)
        try container.encode(priceMin, forKey: .priceMin)
        try container.encode(priceMax, forKey: .priceMax)
        try container.encode(city, forKey: .city)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(lng, forKey: .lng)
        try container.encode(type, forKey: .type)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(contractId, forKey: .contractId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encodeIfPresent(companyName, forKey: .companyName)
        try container.encodeIfPresent(companyLogoUrl, forKey: .companyLogoUrl)
        
        // Encode a single logical key for applications (prefer "applicationsCount").
        try container.encodeIfPresent(applicationsCount, forKey: .applicationsCount)
    }
}

// MARK: - Decoding helpers (réduction de complexité)
private extension Offer {
    static func decodeCategory(from container: KeyedDecodingContainer<CodingKeys>) -> ServiceCategory {
        // Try String + mapping, else decode direct, else fallback
        if let raw = try? container.decode(String.self, forKey: .category),
           let mapped = ServiceCategory(apiValue: raw) {
            return mapped
        }
        if let direct = try? container.decode(ServiceCategory.self, forKey: .category) {
            return direct
        }
        return .carCleaning
    }
    
    static func decodeIntOrString(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Int? {
        if let intVal = try? container.decode(Int.self, forKey: key) { return intVal }
        if let strVal = try? container.decode(String.self, forKey: key),
           let intVal = Int(strVal) { return intVal }
        return nil
    }
    
    static func decodeDoubleIntOrString(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Double? {
        if let dbl = try? container.decode(Double.self, forKey: key) { return dbl }
        if let intVal = try? container.decode(Int.self, forKey: key) { return Double(intVal) }
        if let str = try? container.decode(String.self, forKey: key),
           let dbl = Double(str) { return dbl }
        return nil
    }
    
    static func decodeDoubleOrString(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Double? {
        if let dbl = try? container.decode(Double.self, forKey: key) { return dbl }
        if let str = try? container.decode(String.self, forKey: key),
           let dbl = Double(str) { return dbl }
        return nil
    }
    
    static func decodePostalCode(_ container: KeyedDecodingContainer<CodingKeys>) -> String? {
        if let str = try? container.decode(String.self, forKey: .postalCode) { return str }
        if let intVal = try? container.decode(Int.self, forKey: .postalCode) { return String(intVal) }
        return nil
    }
    
    static func decodeOptionalNonNullString(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> String? {
        // Make the decode optional with try?
        guard let raw = try? container.decode(String.self, forKey: key) else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return (!trimmed.isEmpty && trimmed != "<null>") ? trimmed : nil
    }
    
    static func decodeApplicationsCount(_ container: KeyedDecodingContainer<CodingKeys>) -> Int? {
        // Try "applicationsCount" then "applications", support Int or String (not "<null>")
        if let intVal = try? container.decode(Int.self, forKey: .applicationsCount) { return intVal }
        if let intVal = try? container.decode(Int.self, forKey: .applications) { return intVal }
        if let str = try? container.decode(String.self, forKey: .applicationsCount),
           str != "<null>", let intVal = Int(str) { return intVal }
        if let str = try? container.decode(String.self, forKey: .applications),
           str != "<null>", let intVal = Int(str) { return intVal }
        return nil
    }
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
