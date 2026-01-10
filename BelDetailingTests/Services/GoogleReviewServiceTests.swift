//
//  GoogleReviewServiceTests.swift
//  BelDetailingTests
//
//  Created on 01/01/2026.
//

import XCTest
@testable import BelDetailing

@MainActor
final class GoogleReviewServiceTests: XCTestCase {
    var mockClient: MockNetworkClient!
    var googleReviewService: GoogleReviewServiceNetwork!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        googleReviewService = GoogleReviewServiceNetwork(networkClient: mockClient)
    }
    
    override func tearDown() {
        mockClient.reset()
        mockClient = nil
        googleReviewService = nil
        super.tearDown()
    }
    
    // MARK: - Create Prompt Tests
    
    func testCreatePromptSuccess() async throws {
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
        
        mockClient.setResponse(for: .reviewPromptCreate, value: mockPrompt, wrappedInData: true)
        
        // Act
        let result = await googleReviewService.createPrompt(bookingId: "booking1")
        
        // Assert
        switch result {
        case .success(let prompt):
            XCTAssertEqual(prompt.id, "prompt1")
            XCTAssertEqual(prompt.bookingId, "booking1")
            XCTAssertEqual(prompt.googlePlaceId, "ChIJ...")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testCreatePromptFailure() async throws {
        // Arrange
        mockClient.setError(for: .reviewPromptCreate, error: .networkError("Network error"))
        
        // Act
        let result = await googleReviewService.createPrompt(bookingId: "booking1")
        
        // Assert
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Track Rating Tests
    
    func testTrackRatingSuccess() async throws {
        // Arrange
        mockClient.setResponse(for: .reviewPromptTrackRating(id: "prompt1"), value: EmptyResponse(), wrappedInData: true)
        
        // Act
        let result = await googleReviewService.trackRating(promptId: "prompt1", rating: 5)
        
        // Assert
        switch result {
        case .success(let success):
            XCTAssertTrue(success)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Track Google Redirect Tests
    
    func testTrackGoogleRedirectSuccess() async throws {
        // Arrange
        let mockResponse = GoogleRedirectResponse(
            success: true,
            googlePlaceId: "ChIJ..."
        )
        
        mockClient.setResponse(for: .reviewPromptGoogleRedirect(id: "prompt1"), value: mockResponse, wrappedInData: true)
        
        // Act
        let result = await googleReviewService.trackGoogleRedirect(promptId: "prompt1")
        
        // Assert
        switch result {
        case .success(let redirectResponse):
            XCTAssertTrue(redirectResponse.success)
            XCTAssertEqual(redirectResponse.googlePlaceId, "ChIJ...")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Dismiss Prompt Tests
    
    func testDismissPromptSuccess() async throws {
        // Arrange
        mockClient.setResponse(for: .reviewPromptDismiss(id: "prompt1"), value: EmptyResponse(), wrappedInData: true)
        
        // Act
        let result = await googleReviewService.dismissPrompt(promptId: "prompt1")
        
        // Assert
        switch result {
        case .success(let success):
            XCTAssertTrue(success)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
}

