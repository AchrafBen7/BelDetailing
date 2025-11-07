//
//  Review.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

/// Klantreview over een prestataire (detailer)
struct Review: Codable, Identifiable, Hashable {
    let id: String
    let bookingId: String?
    let providerId: String
    let customerName: String   // bv. "Sophie L."
    let rating: Int            // 1...5
    let comment: String?
    let createdAt: String      // ISO 8601
}

// MARK: - Mock samples
extension Review {
    static var sampleValues: [Review] {
        [
            Review(
                id: "rev_001",
                bookingId: "bkg_001",
                providerId: "prov_001",
                customerName: "Sophie L.",
                rating: 5,
                comment: "Service impeccable, très pro !",
                createdAt: "2025-10-28T10:00:00Z"
            ),
            Review(
                id: "rev_002",
                bookingId: "bkg_002",
                providerId: "prov_001",
                customerName: "Mohamed R.",
                rating: 4,
                comment: "Très bon travail, un peu de retard.",
                createdAt: "2025-10-30T14:30:00Z"
            ),
            Review(
                id: "rev_003",
                bookingId: "bkg_003",
                providerId: "prov_002",
                customerName: "Claire D.",
                rating: 5,
                comment: "Voiture comme neuve !",
                createdAt: "2025-11-02T09:45:00Z"
            )
        ]
    }
}
