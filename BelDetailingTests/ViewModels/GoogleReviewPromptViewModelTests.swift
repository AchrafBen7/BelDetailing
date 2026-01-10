//
//  GoogleReviewPromptViewModelTests.swift
//  BelDetailingTests
//
//  Created on 01/01/2026.
//

import XCTest
@testable import BelDetailing

@MainActor
final class GoogleReviewPromptViewModelTests: XCTestCase {
    var mockClient: MockNetworkClient!
    var engine: Engine!
    var viewModel: GoogleReviewPromptViewModel!
    var booking: Booking!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        engine = Engine(networkClient: NetworkClient(server: .prod))
        
        booking = Booking(
            id: "booking1",
            providerId: "provider1",
            customerId: "customer1",
            providerName: "Test Provider",
            serviceName: "Service Test",
            price: 50.0,
            date: "2026-01-15",
            startTime: "10:00",
            endTime: "12:00",
            address: "123 Rue Test",
            status: .completed,
            paymentStatus: .paid,
            paymentIntentId: "pi_123",
            commissionRate: "0.10",
            invoiceSent: false,
            customer: nil,
            providerBannerUrl: nil,
            currency: "eur",
            progress: nil,
            transportDistanceKm: nil,
            transportFee: nil,
            customerAddressLat: nil,
            customerAddressLng: nil,
            paymentMethod: nil,
            depositAmount: nil,
            depositPaymentIntentId: nil,
            counterProposalDate: nil,
            counterProposalStartTime: nil,
            counterProposalEndTime: nil,
            counterProposalMessage: nil,
            counterProposalStatus: nil,
            createdAt: "2026-01-01T10:00:00Z"
        )
        
        viewModel = GoogleReviewPromptViewModel(booking: booking, engine: engine)
    }
    
    override func tearDown() {
        viewModel = nil
        booking = nil
        engine = nil
        mockClient.reset()
        mockClient = nil
        super.tearDown()
    }
    
    // MARK: - Load or Create Prompt Tests
    
    func testLoadOrCreatePromptSuccess() async throws {
        // Arrange
        let mockPrompt = GoogleReviewPrompt(
            id: "prompt1",
            bookingId: "booking1",
            customerId: "customer1",
            providerId: "provider1",
            googlePlaceId: "ChIJ...",
            ratingSelected: nil,
            promptedAt: "2026-01-01T10:00:00Z",
            googleRedirectedAt: nil,
            dismissedAt: nil,
            createdAt: "2026-01-01T10:00:00Z",
            updatedAt: nil
        )
        
        mockClient.setResponse(for: .reviewPromptGet(bookingId: "booking1"), value: mockPrompt, wrappedInData: true)
        
        // Act
        await viewModel.loadOrCreatePrompt()
        
        // Assert
        XCTAssertNotNil(viewModel.prompt)
        XCTAssertEqual(viewModel.prompt?.id, "prompt1")
    }
    
    func testLoadOrCreatePromptCreatesNewIfNotFound() async throws {
        // Arrange
        // Simuler que le prompt n'existe pas (404)
        mockClient.setError(for: .reviewPromptGet(bookingId: "booking1"), error: .httpError(404, "Not found"))
        
        // Simuler la création d'un nouveau prompt
        let mockPrompt = GoogleReviewPrompt(
            id: "prompt1",
            bookingId: "booking1",
            customerId: "customer1",
            providerId: "provider1",
            googlePlaceId: nil,
            ratingSelected: nil,
            promptedAt: "2026-01-01T10:00:00Z",
            googleRedirectedAt: nil,
            dismissedAt: nil,
            createdAt: "2026-01-01T10:00:00Z",
            updatedAt: nil
        )
        
        mockClient.setResponse(for: .reviewPromptCreate, value: mockPrompt, wrappedInData: true)
        
        // Act
        await viewModel.loadOrCreatePrompt()
        
        // Assert
        XCTAssertNotNil(viewModel.prompt)
        XCTAssertEqual(viewModel.prompt?.bookingId, "booking1")
    }
}

