//
//  ServicePhoto.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

/// Photo associée à un service
struct ServicePhoto: Codable, Identifiable, Hashable {
    let id: String
    let serviceId: String
    let imageUrl: String
    let thumbnailUrl: String? // URL de la version thumbnail optimisée
    let caption: String?
    let displayOrder: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case serviceId = "service_id"
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case caption
        case displayOrder = "display_order"
        case createdAt = "created_at"
    }
    
    init(
        id: String,
        serviceId: String,
        imageUrl: String,
        thumbnailUrl: String? = nil,
        caption: String? = nil,
        displayOrder: Int = 0,
        createdAt: String
    ) {
        self.id = id
        self.serviceId = serviceId
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.caption = caption
        self.displayOrder = displayOrder
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        serviceId = try container.decode(String.self, forKey: .serviceId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        caption = try? container.decode(String.self, forKey: .caption)
        displayOrder = (try? container.decode(Int.self, forKey: .displayOrder)) ?? 0
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}

// MARK: - URL Helpers
extension ServicePhoto {
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

