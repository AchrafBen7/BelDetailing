//
//  ConversationsListView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import Combine

struct ConversationsListView: View {
    @EnvironmentObject var engine: Engine
    @StateObject private var viewModel: ConversationsListViewModel
    @Environment(\.dismiss) var dismiss
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: ConversationsListViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
            } else if viewModel.conversations.isEmpty {
                emptyState
            } else {
                conversationsList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Messages")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .task {
            await viewModel.loadConversations()
        }
    }
    
    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink {
                        ChatView(conversation: conversation, engine: engine)
                    } label: {
                        ConversationRow(conversation: conversation)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Aucun message")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Vos conversations avec les detailers apparaîtront ici")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let logoUrl = conversation.provider?.logoUrl, !logoUrl.isEmpty {
                AsyncImage(url: URL(string: logoUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.provider?.displayName ?? "Detailer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let unreadCount = conversation.unreadCount, unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                } else {
                    Text("Aucun message")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
}

// MARK: - ViewModel

@MainActor
final class ConversationsListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func loadConversations() async {
        isLoading = true
        defer { isLoading = false }
        
        let response = await engine.chatService.getConversations()
        
        switch response {
        case .success(let loadedConversations):
            conversations = loadedConversations
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
