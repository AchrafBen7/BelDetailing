//
//  User.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

enum UserRole: String, Codable, CaseIterable { case customer, company, provider }

struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String
    let phone: String?
    let role: UserRole

    let vatNumber: String?
    let isVatValid: Bool?

    let createdAt: String
    let updatedAt: String

    let customerProfile: CustomerProfile?
    let companyProfile: CompanyProfile?
    let providerProfile: ProviderProfile?
}

// MARK: - Profiles
struct CustomerProfile: Codable, Hashable {
    let firstName: String
    let lastName: String
    let defaultAddress: String?
    let preferredCityId: String?
    let vehicleType: VehicleType?
}

struct CompanyProfile: Codable, Hashable {
    let legalName: String
    let companyTypeId: String
    let city: String?
    let postalCode: String?
    let contactName: String?

    let logoUrl: String?      // ⬅️ NOUVEAU !
}

struct ProviderProfile: Codable, Hashable {
    let displayName: String
    let bio: String?
    let baseCity: String?
    let postalCode: String?
    let hasMobileService: Bool
    let minPrice: Double?
    let rating: Double?
    let services: [String]?
}
