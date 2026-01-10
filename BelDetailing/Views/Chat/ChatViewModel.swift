//
//  ChatViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isSending: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let conversation: Conversation
    private let engine: Engine
    private var pollingTask: Task<Void, Never>?
    private let currentUserId: String
    
    init(conversation: Conversation, engine: Engine) {
        self.conversation = conversation
        self.engine = engine
        
        // Récupérer l'ID de l'utilisateur courant depuis AppSession
        if let user = AppSession.shared.user {
            self.currentUserId = user.id
        } else {
            // Fallback : utiliser customer_id ou provider_id selon le rôle
            self.currentUserId = conversation.customerId
        }
    }
    
    var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isFromCurrentUser(_ message: Message) -> Bool {
        message.senderId == currentUserId
    }
    
    /// Charge les messages de la conversation
    /// ⚡ Optimisé : limite à 50 messages (les plus récents) pour réduire la bande passante
    func loadMessages() async {
        isLoading = true
        defer { isLoading = false }
        
        let response = await engine.chatService.getMessages(conversationId: conversation.id)
        
        switch response {
        case .success(let loadedMessages):
            // Les 50 messages les plus récents sont déjà retournés par le backend
            messages = loadedMessages
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func sendMessage() async {
        guard canSend, !isSending else { return }
        
        let content = messageText.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return }
        
        isSending = true
        defer { isSending = false }
        
        let response = await engine.chatService.sendMessage(
            conversationId: conversation.id,
            content: content
        )
        
        switch response {
        case .success(let message):
            messages.append(message)
            messageText = ""
            // Recharger pour avoir les dernières données
            await loadMessages()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func markAsRead() async {
        _ = await engine.chatService.markAsRead(conversationId: conversation.id)
    }
    
    /// Démarre le polling pour recharger les messages automatiquement
    /// ⚡ Optimisé : polling toutes les 5 secondes + limite à 50 messages
    func startPolling() {
        pollingTask = Task {
            while !Task.isCancelled {
                // Polling toutes les 5 secondes (optimisation bande passante)
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 secondes
                await loadMessages() // Charge seulement les 50 derniers messages
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
