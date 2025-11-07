//
//  ApplicationOffer.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

struct Application: Codable, Identifiable, Hashable {
    let id: String
    let offerId: String
    let providerId: String
    let message: String?
    let attachments: [Attachment]?
    let status: ApplicationStatus
    let createdAt: String
    let updatedAt: String
    let providerName: String
    let ratingAfterContract: Int?
}

enum ApplicationStatus: String, Codable, CaseIterable {
    case submitted
    case underReview
    case accepted
    case refused
    case withdrawn
}

// MARK: - Mock samples
extension Application {
    static var sampleValues: [Application] {
        [
            Application(
                id: "app_001",
                offerId: "off_001",
                providerId: "prov_001",
                message: "Bonjour, nous avons une équipe de 5 personnes expérimentées pour entretenir votre flotte.",
                attachments: [
                    Attachment(
                        id: "att_100",
                        fileName: "Portfolio_AutoClean.pdf",
                        url: "https://cdn.example.com/portfolios/autoclean.pdf",
                        mimeType: "application/pdf",
                        sizeBytes: 400_000
                    )
                ],
                status: .submitted,
                createdAt: "2025-11-07T09:00:00Z",
                updatedAt: "2025-11-07T09:00:00Z",
                providerName: "AutoClean Pro",
                ratingAfterContract: nil
            ),
            Application(
                id: "app_002",
                offerId: "off_001",
                providerId: "prov_002",
                message: "Disponible dès décembre. Nous proposons un service mobile sur tout Bruxelles.",
                attachments: nil,
                status: .underReview,
                createdAt: "2025-11-07T10:30:00Z",
                updatedAt: "2025-11-07T10:30:00Z",
                providerName: "BruxDetail",
                ratingAfterContract: nil
            )
        ]
    }
}
