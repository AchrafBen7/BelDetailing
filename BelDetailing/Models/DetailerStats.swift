//
//  DetailerStats.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

struct DetailerStats: Codable, Hashable {
    let monthlyEarnings: Double
    let variationPercent: Double
    let reservationsCount: Int
    let rating: Double
    let clientsCount: Int
}
