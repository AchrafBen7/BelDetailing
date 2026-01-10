//
//  ChatView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @EnvironmentObject var engine: Engine
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ChatViewModel
    
    init(conversation: Conversation, engine: Engine) {
        self.conversation = conversation
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversation: conversation, engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                chatHeader
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: viewModel.isFromCurrentUser(message)
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input
                messageInput
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMessages()
            await viewModel.markAsRead()
        }
        .onAppear {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
    
    // MARK: - Header
    
    private var chatHeader: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
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
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.provider?.displayName ?? "Detailer")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if let booking = conversation.booking {
                    Text(booking.serviceName ?? "Service")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
    
    // MARK: - Input
    
    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Tapez un message...", text: $viewModel.messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)
                .lineLimit(1...5)
            
            Button {
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.canSend ? .white : .gray)
            }
            .disabled(!viewModel.canSend || viewModel.isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
}

