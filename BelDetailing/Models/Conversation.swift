//
//  Conversation.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

// MARK: - Conversation Model

struct Conversation: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let customerId: String
    let bookingId: String?
    let lastMessageAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    // Relations (optionnelles, chargées séparément)
    let provider: ConversationProvider?
    let customer: ConversationCustomer?
    let booking: ConversationBooking?
    let lastMessage: Message?
    let unreadCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerId = "provider_id"
        case customerId = "customer_id"
        case bookingId = "booking_id"
        case lastMessageAt = "last_message_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case provider
        case customer
        case booking
        case lastMessage = "lastMessage"
        case unreadCount = "unreadCount"
    }
}

// MARK: - Conversation Provider Info

struct ConversationProvider: Codable, Hashable {
    let displayName: String?
    let logoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case logoUrl = "logo_url"
    }
}

// MARK: - Conversation Customer Info

struct ConversationCustomer: Codable, Hashable {
    let id: String
    let email: String?
}

// MARK: - Conversation Booking Info

struct ConversationBooking: Codable, Hashable {
    let id: String
    let serviceName: String?
    let date: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case serviceName = "service_name"
        case date
        case status
    }
}

