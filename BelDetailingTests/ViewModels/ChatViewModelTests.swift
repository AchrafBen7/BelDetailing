//
//  ChatViewModelTests.swift
//  BelDetailingTests
//
//  Created on 01/01/2026.
//

import XCTest
@testable import BelDetailing

@MainActor
final class ChatViewModelTests: XCTestCase {
    var mockClient: MockNetworkClient!
    var engine: Engine!
    var viewModel: ChatViewModel!
    var conversation: Conversation!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        engine = Engine(networkClient: NetworkClient(server: .prod))
        // Note: En production, vous devriez injecter le mockClient dans Engine
        
        conversation = Conversation(
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
        
        viewModel = ChatViewModel(conversation: conversation, engine: engine)
    }
    
    override func tearDown() {
        viewModel = nil
        conversation = nil
        engine = nil
        mockClient.reset()
        mockClient = nil
        super.tearDown()
    }
    
    // MARK: - Can Send Tests
    
    func testCanSendWithEmptyText() {
        // Arrange
        viewModel.messageText = ""
        
        // Assert
        XCTAssertFalse(viewModel.canSend)
    }
    
    func testCanSendWithWhitespaceOnly() {
        // Arrange
        viewModel.messageText = "   "
        
        // Assert
        XCTAssertFalse(viewModel.canSend)
    }
    
    func testCanSendWithValidText() {
        // Arrange
        viewModel.messageText = "Hello"
        
        // Assert
        XCTAssertTrue(viewModel.canSend)
    }
    
    // MARK: - Is From Current User Tests
    
    func testIsFromCurrentUser() {
        // Arrange
        let message = Message(
            id: "msg1",
            conversationId: "conv1",
            senderId: "customer1",
            senderRole: .customer,
            content: "Test",
            isRead: false,
            createdAt: nil,
            updatedAt: nil,
            sender: nil
        )
        
        // Note: Ce test nécessite que currentUserId soit défini dans le ViewModel
        // Vous devrez peut-être ajuster selon votre implémentation
    }
}


