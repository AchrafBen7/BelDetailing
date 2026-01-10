//
//  ChatServiceTests.swift
//  BelDetailingTests
//
//  Created on 01/01/2026.
//

import XCTest
@testable import BelDetailing

@MainActor
final class ChatServiceTests: XCTestCase {
    var mockClient: MockNetworkClient!
    var chatService: ChatServiceNetwork!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        chatService = ChatServiceNetwork(networkClient: mockClient)
    }
    
    override func tearDown() {
        mockClient.reset()
        mockClient = nil
        chatService = nil
        super.tearDown()
    }
    
    // MARK: - Get Conversations Tests
    
    func testGetConversationsSuccess() async throws {
        // Arrange
        let mockConversations = [
            Conversation(
                id: "conv1",
                providerId: "provider1",
                customerId: "customer1",
                bookingId: "booking1",
                lastMessageAt: "2026-01-01T10:00:00Z",
                createdAt: "2026-01-01T09:00:00Z",
                updatedAt: "2026-01-01T10:00:00Z",
                provider: ConversationProvider(displayName: "Test Provider", logoUrl: nil),
                customer: ConversationCustomer(id: "customer1", email: "test@example.com"),
                booking: ConversationBooking(id: "booking1", serviceName: "Service", date: "2026-01-01", status: "confirmed"),
                lastMessage: nil,
                unreadCount: 2
            )
        ]
        
        mockClient.setResponse(for: .chatConversationsList, value: mockConversations, wrappedInData: true)
        
        // Act
        let result = await chatService.getConversations()
        
        // Assert
        switch result {
        case .success(let conversations):
            XCTAssertEqual(conversations.count, 1)
            XCTAssertEqual(conversations.first?.id, "conv1")
            XCTAssertEqual(conversations.first?.unreadCount, 2)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testGetConversationsFailure() async throws {
        // Arrange
        mockClient.setError(for: .chatConversationsList, error: .networkError("Network error"))
        
        // Act
        let result = await chatService.getConversations()
        
        // Assert
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Get Messages Tests
    
    func testGetMessagesSuccess() async throws {
        // Arrange
        let mockMessages = [
            Message(
                id: "msg1",
                conversationId: "conv1",
                senderId: "customer1",
                senderRole: .customer,
                content: "Hello",
                isRead: false,
                createdAt: "2026-01-01T10:00:00Z",
                updatedAt: nil,
                sender: MessageSender(id: "customer1", email: "test@example.com")
            )
        ]
        
        mockClient.setResponse(for: .chatMessages(conversationId: "conv1"), value: mockMessages, wrappedInData: true)
        
        // Act
        let result = await chatService.getMessages(conversationId: "conv1")
        
        // Assert
        switch result {
        case .success(let messages):
            XCTAssertEqual(messages.count, 1)
            XCTAssertEqual(messages.first?.content, "Hello")
            XCTAssertEqual(messages.first?.senderRole, .customer)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Send Message Tests
    
    func testSendMessageSuccess() async throws {
        // Arrange
        let mockMessage = Message(
            id: "msg1",
            conversationId: "conv1",
            senderId: "customer1",
            senderRole: .customer,
            content: "Test message",
            isRead: false,
            createdAt: "2026-01-01T10:00:00Z",
            updatedAt: nil,
            sender: nil
        )
        
        mockClient.setResponse(for: .chatSendMessage(conversationId: "conv1"), value: mockMessage, wrappedInData: true)
        
        // Act
        let result = await chatService.sendMessage(conversationId: "conv1", content: "Test message")
        
        // Assert
        switch result {
        case .success(let message):
            XCTAssertEqual(message.content, "Test message")
            XCTAssertEqual(message.conversationId, "conv1")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Create Conversation Tests
    
    func testCreateOrGetConversationSuccess() async throws {
        // Arrange
        let mockConversation = Conversation(
            id: "conv1",
            providerId: "provider1",
            customerId: "customer1",
            bookingId: "booking1",
            lastMessageAt: nil,
            createdAt: "2026-01-01T10:00:00Z",
            updatedAt: nil,
            provider: nil,
            customer: nil,
            booking: nil,
            lastMessage: nil,
            unreadCount: nil
        )
        
        mockClient.setResponse(for: .chatConversationCreate, value: mockConversation, wrappedInData: true)
        
        // Act
        let result = await chatService.createOrGetConversation(
            providerId: "provider1",
            customerId: "customer1",
            bookingId: "booking1"
        )
        
        // Assert
        switch result {
        case .success(let conversation):
            XCTAssertEqual(conversation.id, "conv1")
            XCTAssertEqual(conversation.bookingId, "booking1")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
}


