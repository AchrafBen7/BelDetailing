//
//  ChatService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

// MARK: - ChatService Protocol

protocol ChatService {
    func getConversations() async -> APIResponse<[Conversation]>
    func getConversation(id: String) async -> APIResponse<Conversation>
    func createOrGetConversation(providerId: String?, customerId: String?, bookingId: String) async -> APIResponse<Conversation>
    func getMessages(conversationId: String) async -> APIResponse<[Message]>
    func sendMessage(conversationId: String, content: String) async -> APIResponse<Message>
    func markAsRead(conversationId: String) async -> APIResponse<Bool>
}

// MARK: - Network Implementation

final class ChatServiceNetwork: ChatService {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getConversations() async -> APIResponse<[Conversation]> {
        await networkClient.call(endPoint: .chatConversationsList)
    }
    
    func getConversation(id: String) async -> APIResponse<Conversation> {
        await networkClient.call(endPoint: .chatConversationDetail(id: id))
    }
    
    func createOrGetConversation(providerId: String?, customerId: String?, bookingId: String) async -> APIResponse<Conversation> {
        var payload: [String: Any] = [
            "booking_id": bookingId
        ]
        
        if let providerId = providerId {
            payload["provider_id"] = providerId
        }
        
        if let customerId = customerId {
            payload["customer_id"] = customerId
        }
        
        return await networkClient.call(
            endPoint: .chatConversationCreate,
            dict: payload
        )
    }
    
    /// Récupère les messages d'une conversation
    /// ⚡ Limité à 50 messages par défaut pour optimiser la bande passante
    /// Les 50 messages les plus récents sont retournés
    func getMessages(conversationId: String) async -> APIResponse<[Message]> {
        await networkClient.call(endPoint: .chatMessages(conversationId: conversationId))
    }
    
    func sendMessage(conversationId: String, content: String) async -> APIResponse<Message> {
        let payload: [String: Any] = [
            "content": content
        ]
        
        return await networkClient.call(
            endPoint: .chatSendMessage(conversationId: conversationId),
            dict: payload
        )
    }
    
    func markAsRead(conversationId: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .chatMarkAsRead(conversationId: conversationId)
        )
        
        switch response {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
}

