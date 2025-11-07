//
//  DetailerStats.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

struct DetailerStats: Codable, Hashable {
    let totalBookings: Int
    let completedBookings: Int
    let ratingAverage: Double
    let totalReviews: Int
    let revenueMonth: Double
    let activeOffers: Int
}

extension DetailerStats {
    static let sample = DetailerStats(
        totalBookings: 87,
        completedBookings: 81,
        ratingAverage: 4.8,
        totalReviews: 45,
        revenueMonth: 2460.0,
        activeOffers: 3
    )
}
