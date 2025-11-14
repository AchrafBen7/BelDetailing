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

// MARK: - Sample Data
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

    static let sampleCompany = User(
        id: "usr_company001",
        email: "garage@elitecar.be",
        phone: "+32470123456",
        role: .company,
        vatNumber: "BE0456123456",
        isVatValid: true,
        createdAt: "2025-11-07T10:00:00Z",
        updatedAt: "2025-11-07T10:00:00Z",
        customerProfile: nil,
        companyProfile: CompanyProfile(
            legalName: "EliteCar Detailing SRL",
            companyTypeId: "garage",
            city: "Bruxelles",
            postalCode: "1000",
            contactName: "Yassine",
            logoUrl: "https://yourcdn.com/logos/elitecar.png"
        ),
        providerProfile: nil
    )

    static let sampleProvider = User(
        id: "usr_provider001",
        email: "pro@example.com",
        phone: "+32470123456",
        role: .provider,
        vatNumber: "BE0123456789",
        isVatValid: true,
        createdAt: "2025-11-07T10:00:00Z",
        updatedAt: "2025-11-07T10:00:00Z",
        customerProfile: nil,
        companyProfile: nil,
        providerProfile: ProviderProfile(
            displayName: "ShinyCar Detail",
            bio: "Spécialiste du detailing automobile à Bruxelles.",
            baseCity: "Bruxelles",
            postalCode: "1000",
            hasMobileService: true,
            minPrice: 50,
            rating: 4.8,
            services: ["interior", "exterior", "polishing"]
        )
    )
}
