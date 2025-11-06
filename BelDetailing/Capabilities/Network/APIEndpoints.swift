//
//  APIEndpoints.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - HTTP Methods
enum HTTPVerb: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Endpoints
enum APIEndPoint {
    // MARK: Auth
    case register
    case login
    case refresh
    case me
    case updateProfile
    
    // MARK: Providers
    case providersList
    case providerDetail(id: String)
    case providerReviews(providerId: String)
    case providerServices(providerId: String)
    
    // MARK: Bookings
    case bookingsList(scope: String?, status: String?)
    case bookingCreate
    case bookingUpdate(id: String)
    case bookingCancel(id: String)
    case bookingConfirm(id: String)
    case bookingDecline(id: String)
    
    // MARK: Catalog & Static
    case cities
    case serviceCategories
    
    // MARK: Payments
    case paymentIntent
}

// MARK: - Mapper Protocol
protocol EndpointMapper {
    static func path(for endPoint: APIEndPoint) -> String
    static func method(for endPoint: APIEndPoint) -> HTTPVerb
}

// MARK: - Mapper Implementation
struct BelDetailingEndpointMapper: EndpointMapper {
    static func path(for endPoint: APIEndPoint) -> String {
        switch endPoint {
            
        // MARK: Auth
        case .register:
            return "api/v1/auth/register"
        case .login:
            return "api/v1/auth/login"
        case .refresh:
            return "api/v1/auth/refresh"
        case .me, .updateProfile:
            return "api/v1/me"
            
        // MARK: Providers
        case .providersList:
            return "api/v1/providers"
        case .providerDetail(let id):
            return "api/v1/providers/\(id)"
        case .providerReviews(let providerId):
            return "api/v1/providers/\(providerId)/reviews"
        case .providerServices(let providerId):
            return "api/v1/providers/\(providerId)/services"
            
        // MARK: Bookings
        case .bookingsList:
            return "api/v1/bookings"
        case .bookingCreate:
            return "api/v1/bookings"
        case .bookingUpdate(let id):
            return "api/v1/bookings/\(id)"
        case .bookingCancel(let id):
            return "api/v1/bookings/\(id)/cancel"
        case .bookingConfirm(let id):
            return "api/v1/bookings/\(id)/confirm"
        case .bookingDecline(let id):
            return "api/v1/bookings/\(id)/decline"
            
        // MARK: Catalog
        case .cities:
            return "api/v1/cities"
        case .serviceCategories:
            return "api/v1/service-categories"
            
        // MARK: Payments
        case .paymentIntent:
            return "api/v1/payments/intent"
        }
    }
    
    static func method(for endPoint: APIEndPoint) -> HTTPVerb {
        switch endPoint {
            
        // Auth
        case .register, .login, .refresh:
            return .post
        case .updateProfile:
            return .patch
        case .me:
            return .get
            
        // Providers
        case .providersList, .providerDetail, .providerReviews, .providerServices:
            return .get
            
        // Bookings
        case .bookingsList:
            return .get
        case .bookingCreate:
            return .post
        case .bookingUpdate:
            return .patch
        case .bookingCancel, .bookingConfirm, .bookingDecline:
            return .post
            
        // Catalog
        case .cities, .serviceCategories:
            return .get
            
        // Payments
        case .paymentIntent:
            return .post
        }
    }
}
