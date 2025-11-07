//
//  User.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

// Model/User.swift

import Foundation

enum UserRole: String, Codable, CaseIterable { case customer, company, provider }

struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String
    let phone: String?
    let role: UserRole

    let vatNumber: String?          // TVA requise si company/provider
    let isVatValid: Bool?           // résultat de la vérif TVA

    let createdAt: String
    let updatedAt: String

    let customerProfile: CustomerProfile?
    let companyProfile: CompanyProfile?
    let providerProfile: ProviderProfile?
}

struct CustomerProfile: Codable, Hashable {
    let firstName: String
    let lastName: String
    let defaultAddress: String?
    let preferredCityId: String?
}

// ⚠️ companyTypeId = identifiant “libre” (ex: "garage", "leasing", …)
// Le nom affiché est LOCALISÉ via Localizable: "companyType.garage", etc.
struct CompanyProfile: Codable, Hashable {
    let legalName: String
    let companyTypeId: String              // pas d'enum figée
    let city: String?
    let postalCode: String?
    let contactName: String?
}

struct ProviderProfile: Codable, Hashable {
    let displayName: String
    let bio: String?
    let baseCity: String?
    let postalCode: String?
    let hasMobileService: Bool
    let minPrice: Double?
    let rating: Double?
    let services: [String]?                // ex: ServiceCategory rawValues
}

extension User {
    static let sampleCustomer = User(
        id: "usr_001",
        email: "achraf@example.com",
        phone: "+32470123456",
        role: .customer,
        vatNumber: nil,
        isVatValid: nil,
        createdAt: "2025-11-07T10:00:00Z",
        updatedAt: "2025-11-07T10:00:00Z",
        customerProfile: CustomerProfile(
            firstName: "Achraf",
            lastName: "Benali",
            defaultAddress: "Avenue Louise 123, 1000 Bruxelles",
            preferredCityId: "city_001"
        ),
        companyProfile: nil,
        providerProfile: nil
    )
}
