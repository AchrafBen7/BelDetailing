//
//  PortfolioPhoto.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

/// Photo du portfolio d'un provider (travaux précédents)
struct PortfolioPhoto: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let imageUrl: String
    let thumbnailUrl: String? // URL de la version thumbnail optimisée
    let caption: String?
    let serviceCategory: ServiceCategory?
    let createdAt: String
    let displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerId = "provider_id"
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case caption
        case serviceCategory = "service_category"
        case createdAt = "created_at"
        case displayOrder = "display_order"
    }
    
    init(
        id: String,
        providerId: String,
        imageUrl: String,
        thumbnailUrl: String? = nil,
        caption: String? = nil,
        serviceCategory: ServiceCategory? = nil,
        createdAt: String,
        displayOrder: Int = 0
    ) {
        self.id = id
        self.providerId = providerId
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.caption = caption
        self.serviceCategory = serviceCategory
        self.createdAt = createdAt
        self.displayOrder = displayOrder
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        providerId = try container.decode(String.self, forKey: .providerId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        caption = try? container.decode(String.self, forKey: .caption)
        
        // Service category: optional, decode as string then convert
        if let categoryString = try? container.decode(String.self, forKey: .serviceCategory) {
            serviceCategory = ServiceCategory(rawValue: categoryString)
        } else {
            serviceCategory = nil
        }
        
        createdAt = try container.decode(String.self, forKey: .createdAt)
        displayOrder = (try? container.decode(Int.self, forKey: .displayOrder)) ?? 0
    }
}

// MARK: - URL Helpers
extension PortfolioPhoto {
    var imageURL: URL? {
        URL(string: imageUrl)
    }
    
    var thumbnailImageURL: URL? {
        if let thumbnailUrl = thumbnailUrl {
            return URL(string: thumbnailUrl)
        }
        return imageURL // Fallback sur l'image full si pas de thumbnail
    }
}

