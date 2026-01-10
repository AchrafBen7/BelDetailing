//
//  Message.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

// MARK: - Message Model

struct Message: Codable, Identifiable, Hashable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderRole: MessageSenderRole
    let content: String
    let isRead: Bool
    let createdAt: String?
    let updatedAt: String?
    
    // Relation (optionnelle)
    let sender: MessageSender?
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case senderRole = "sender_role"
        case content
        case isRead = "is_read"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sender
    }
}

// MARK: - Message Sender Role

enum MessageSenderRole: String, Codable {
    case provider
    case customer
}

// MARK: - Message Sender Info

struct MessageSender: Codable, Hashable {
    let id: String
    let email: String?
}

// MARK: - Create Message Request

struct CreateMessageRequest: Codable {
    let content: String
}

