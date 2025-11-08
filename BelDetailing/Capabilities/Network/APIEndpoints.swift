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
    case providerStats(providerId: String)

    // MARK: Reviews (nieuw voor creatie)
    case providerReviewCreate

    
    // MARK: Bookings
    case bookingsList(scope: String?, status: String?)
    case bookingCreate
    case bookingUpdate(id: String)
    case bookingCancel(id: String)
    case bookingConfirm(id: String)
    case bookingDecline(id: String)
    
    // MARK: Offers
    case offersList
    case offerDetail(id: String)
    case offerCreate
    case offerUpdate(id: String)
    case offerClose(id: String)    // ✅ ajouté
    case offerDelete(id: String)
    // MARK: Search
    case searchProviders
    case searchOffers

    // MARK: Offer Applications
    case offerApplications(offerId: String)
    case offerApply(offerId: String)
    case applicationWithdraw(id: String)
    case applicationAccept(id: String)
    case applicationRefuse(id: String)
    // MARK: - Utilities
    case vatValidate(number: String)
   
    // MARK: Catalog
    case cities
    case serviceCategories
    // MARK: Media
    case mediaUpload
    case mediaDelete(id: String)

    // MARK: Notifications
    case notificationsList
    case notificationRead(id: String)
    case notificationSubscribe(topic: String)

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
        case .providerStats(let providerId):
            return "api/v1/providers/\(providerId)/stats"
        case .providerReviewCreate:
            return "api/v1/reviews" // of "api/v1/providers/:id/reviews" als je dat verkiest

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
        case .offerClose(let id):                    // ✅ ici
            return "api/v1/offers/\(id)/close"
        case .offerDelete(let id):
            return "api/v1/offers/\(id)"
        case .vatValidate(let number):
            return "api/v1/utils/vat/validate?number=\(number)"

        // MARK: Applications
        case .offerApplications(let offerId):
            return "api/v1/offers/\(offerId)/applications"
        case .offerApply(let offerId):
            return "api/v1/offers/\(offerId)/apply"
        case .applicationWithdraw(let id):
            return "api/v1/applications/\(id)/withdraw"
        case .applicationAccept(let id):
            return "api/v1/applications/\(id)/accept"
        case .applicationRefuse(let id):
            return "api/v1/applications/\(id)/refuse"
        // MARK: Search
        case .searchProviders:
            return "api/v1/search/providers"
        case .searchOffers:
            return "api/v1/search/offers"

        // MARK: Catalog
        case .cities:
            return "api/v1/cities"
        case .serviceCategories:
            return "api/v1/service-categories"
            // MARK: Media
        case .mediaUpload: return "api/v1/media/upload"
        case .mediaDelete(let id): return "api/v1/media/\(id)"
            // MARK: Notifications
        case .notificationsList: return "api/v1/notifications"
        case .notificationRead(let id): return "api/v1/notifications/\(id)/read"
        case .notificationSubscribe(let topic): return "api/v1/notifications/subscribe?topic=\(topic)"

        // MARK: Payments
        case .paymentIntent:
            return "api/v1/payments/intent"
        }
    }
    
    static func method(for endPoint: APIEndPoint) -> HTTPVerb {
        switch endPoint {
            
        // MARK: Auth
        case .register, .login, .refresh:
            return .post
        case .updateProfile:
            return .patch
        case .profile:
            return .get
            
        // MARK: Providers
        case .providersList, .providerDetail, .providerReviews, .providerServices, .providerStats:
            return .get
        case .providerReviewCreate:
            return .post
            
        // MARK: Bookings
        case .bookingsList:
            return .get
        case .bookingCreate:
            return .post
        case .bookingUpdate:
            return .patch
        case .bookingCancel, .bookingConfirm, .bookingDecline:
            return .post
        // MARK: Search
        case .searchProviders, .searchOffers:
            return .get

        // MARK: Offers
        case .offersList, .offerDetail:
            return .get
        case .offerCreate:
            return .post
        case .offerUpdate:
            return .patch
        case .offerClose:
            return .post
        case .offerDelete:
            return .delete
        case .vatValidate:
            return .get

        // MARK: Applications
        case .offerApplications:
            return .get
        case .offerApply:
            return .post
        case .applicationWithdraw, .applicationAccept, .applicationRefuse:
            return .post

        // MARK: Catalog
        case .cities, .serviceCategories:
            return .get
            
        // MARK: Payments
        case .paymentIntent:
            return .post

        // MARK: Media
        case .mediaUpload:
            return .post
        case .mediaDelete:
            return .delete

        // MARK: Notifications
        case .notificationsList:
            return .get
        case .notificationRead:
            return .patch
        case .notificationSubscribe:
            return .post
        }
    }

}
