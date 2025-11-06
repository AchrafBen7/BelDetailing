//
//  APIEndpoints.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//
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
    case profile
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
    
    // MARK: Offers (New)
    case offersList
    case offerDetail(id: String)
    case offerCreate
    case offerUpdate(id: String)
    case offerDelete(id: String)
    
    // MARK: Offer Applications (Prestataire → Offre)
    case offerApplications(offerId: String)
    case applyToOffer(offerId: String)
    case withdrawApplication(offerId: String, applicationId: String)
    
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
        case .profile, .updateProfile:
            return "api/v1/profile"
            
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
            
        // MARK: Offers
        case .offersList:
            return "api/v1/offers"
        case .offerDetail(let id):
            return "api/v1/offers/\(id)"
        case .offerCreate:
            return "api/v1/offers"
        case .offerUpdate(let id):
            return "api/v1/offers/\(id)"
        case .offerDelete(let id):
            return "api/v1/offers/\(id)"
            
        // MARK: Offer Applications
        case .offerApplications(let offerId):
            return "api/v1/offers/\(offerId)/applications"
        case .applyToOffer(let offerId):
            return "api/v1/offers/\(offerId)/apply"
        case .withdrawApplication(let offerId, let applicationId):
            return "api/v1/offers/\(offerId)/applications/\(applicationId)/withdraw"
            
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
        case .profile:
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
            
        // Offers
        case .offersList, .offerDetail:
            return .get
        case .offerCreate:
            return .post
        case .offerUpdate:
            return .patch
        case .offerDelete:
            return .delete
            
        // Offer Applications
        case .offerApplications:
            return .get
        case .applyToOffer:
            return .post
        case .withdrawApplication:
            return .delete
            
        // Catalog
        case .cities, .serviceCategories:
            return .get
            
        // Payments
        case .paymentIntent:
            return .post
        }
    }
}
