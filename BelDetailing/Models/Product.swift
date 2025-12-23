//
//  Product.swift
//  BelDetailing
//

import Foundation

struct Product: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let category: ProductCategory
    let level: String?
    let price: Double
    let promoPrice: Double?
    let imageUrl: String?
    let affiliateUrl: String?
    let partnerName: String?
    let rating: Double
    let reviewCount: Int
}

// MARK: - Helpers
extension Product {
    var imageURL: URL? {
        guard let imageUrl, let url = URL(string: imageUrl) else { return nil }
        return url
    }

    var affiliateURL: URL? {
        guard let affiliateUrl, let url = URL(string: affiliateUrl) else { return nil }
        return url
    }

    var formattedPrice: String {
        String(format: "€%.2f", price)
    }

    var formattedPromoPrice: String? {
        guard let promoPrice else { return nil }
        return String(format: "€%.2f", promoPrice)
    }
}
