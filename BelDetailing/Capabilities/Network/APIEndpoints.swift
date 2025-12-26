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
enum APIEndPoint: Equatable  {
    // Auth
    case register, login, refresh
    case profile, updateProfile
    case loginApple
    case loginGoogle
    case logout
    
    // Providers
    case providersList
    case providerDetail(id: String)
    case providerReviews(providerId: String)
    case providerServices(providerId: String)
    case providerStats(providerId: String)
    case providerReviewCreate

    // JWT-based provider endpoints
    case providerMyStats
    case providerMyServices
    case providerMyReviews
    case providerServiceCreate            // ⬅️ AJOUT: création d’un service (POST /providers/services)
    
    // Bookings
    case bookingsList(scope: String?, status: String?)
    case bookingCreate
    case bookingUpdate(id: String)
    case bookingCancel(id: String)
    case bookingConfirm(id: String)
    case bookingDecline(id: String)
    
    // Offers
    case offersList
    case offerDetail(id: String)
    case offerCreate
    case offerUpdate(id: String)
    case offerClose(id: String)
    case offerDelete(id: String)
    
    // Search
    case searchProviders
    case searchOffers
    
    // Offer Applications
    case offerApplications(offerId: String)
    case offerApply(offerId: String)
    case applicationWithdraw(id: String)
    case applicationAccept(id: String)
    case applicationRefuse(id: String)
    
    // Utilities
    case vatValidate(number: String)
    
    // Catalog
    case cities
    case serviceCategories
    
    // Media
    case mediaUpload
    case mediaDelete(id: String)
    
    // Notifications
    case notificationsList
    case notificationRead(id: String)
    case notificationSubscribe(topic: String)
    
    // Payments
    case paymentIntent
    case paymentCapture
    case paymentRefund
    case paymentSetupIntent
    case paymentMethods
    case paymentTransactions
    case paymentMethodDelete(id: String)

    // Products
    case products
    case productsRecommended
    case productClick(id: String)

    // Taxes
    case taxesSummary
    case taxesDocuments
    case taxesDownload(id: String)
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
        case .register, .login, .refresh, .profile, .updateProfile, .loginApple, .loginGoogle, .logout:
            return authPath(for: endPoint)

        case .providersList, .providerDetail, .providerReviews, .providerServices, .providerStats, .providerReviewCreate,
             .providerMyStats, .providerMyServices, .providerMyReviews, .providerServiceCreate:
            return providerPath(for: endPoint)

        case .bookingsList, .bookingCreate, .bookingUpdate, .bookingCancel, .bookingConfirm, .bookingDecline:
            return bookingPath(for: endPoint)

        case .offersList, .offerDetail, .offerCreate, .offerUpdate, .offerClose, .offerDelete:
            return offerPath(for: endPoint)

        case .searchProviders, .searchOffers:
            return searchPath(for: endPoint)

        case .offerApplications, .offerApply, .applicationWithdraw, .applicationAccept, .applicationRefuse:
            return applicationPath(for: endPoint)

        case .vatValidate:
            return vatPath(for: endPoint)

        case .cities, .serviceCategories:
            return catalogPath(for: endPoint)

        case .mediaUpload, .mediaDelete:
            return mediaPath(for: endPoint)

        case .notificationsList, .notificationRead, .notificationSubscribe:
            return notificationPath(for: endPoint)

        case .paymentIntent, .paymentCapture, .paymentRefund, .paymentSetupIntent, .paymentMethods, .paymentTransactions, .paymentMethodDelete:
            return paymentsPath(for: endPoint)

        case .products, .productsRecommended, .productClick:
            return productsPath(for: endPoint)

        case .taxesSummary, .taxesDocuments, .taxesDownload:
            return taxesPath(for: endPoint)
        }
    }

    static func method(for endPoint: APIEndPoint) -> HTTPVerb {
        switch endPoint {
        case .register, .login, .refresh, .loginApple, .loginGoogle, .logout, .providerReviewCreate, .bookingCreate, .bookingCancel,
             .bookingConfirm, .bookingDecline, .offerCreate, .offerClose, .offerApply,
             .applicationWithdraw, .applicationAccept, .applicationRefuse,
             .notificationSubscribe, .paymentIntent, .paymentCapture, .paymentRefund, .mediaUpload,
             .productClick,
             .paymentSetupIntent,
             .providerServiceCreate:         // ⬅️ AJOUT: POST
            return .post

        case .updateProfile, .bookingUpdate, .offerUpdate, .notificationRead:
            return .patch

        case .providerDetail, .providersList, .providerReviews, .providerServices,
             .providerStats, .providerMyStats, .providerMyServices, .providerMyReviews,
             .offersList, .offerDetail, .bookingsList,
             .cities, .serviceCategories, .searchProviders, .searchOffers,
             .offerApplications, .profile, .notificationsList, .vatValidate,
             .products, .productsRecommended,
             .paymentMethods, .paymentTransactions,
             .taxesSummary, .taxesDocuments, .taxesDownload:
            return .get

        case .offerDelete, .mediaDelete, .paymentMethodDelete:
            return .delete
        }
    }

    static func paymentsPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .paymentIntent:
            return "api/v1/payments/intent"
        case .paymentCapture:
            return "api/v1/payments/capture"
        case .paymentRefund:
            return "api/v1/payments/refund"
        case .paymentSetupIntent:
            return "api/v1/payments/setup-intent"
        case .paymentMethods:
            return "api/v1/payments/methods"
        case .paymentTransactions:
            return "api/v1/payments/transactions"
        case .paymentMethodDelete(let id):
            return "api/v1/payments/methods/\(id)"
        default:
            return ""
        }
    }
}

// MARK: - Helper sub-switches
private extension BelDetailingEndpointMapper {
    static func authPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .register: return "api/v1/auth/register"
        case .login: return "api/v1/auth/login"
        case .refresh: return "api/v1/auth/refresh"
        case .loginApple: return "api/v1/auth/apple"
        case .loginGoogle: return "api/v1/auth/google"
        case .profile, .updateProfile: return "api/v1/profile"
        case .logout: return "api/v1/auth/logout"
        default: return ""
        }
    }
    
    static func providerPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .providersList: return "api/v1/providers"
        case .providerDetail(let id): return "api/v1/providers/\(id)"
        case .providerReviews(let id): return "api/v1/providers/\(id)/reviews"
        case .providerServices(let id): return "api/v1/providers/\(id)/services"
        case .providerStats(let id): return "api/v1/providers/\(id)/stats"
        case .providerMyStats: return "api/v1/providers/me/stats"
        case .providerMyServices: return "api/v1/providers/me/services"
        case .providerMyReviews: return "api/v1/providers/me/reviews"
        case .providerReviewCreate: return "api/v1/reviews"
        case .providerServiceCreate: return "api/v1/providers/services"   // ⬅️ AJOUT
        default: return ""
        }
    }
    
    static func bookingPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .bookingsList, .bookingCreate: return "api/v1/bookings"
        case .bookingUpdate(let id): return "api/v1/bookings/\(id)"
        case .bookingCancel(let id): return "api/v1/bookings/\(id)/cancel"
        case .bookingConfirm(let id): return "api/v1/bookings/\(id)/confirm"
        case .bookingDecline(let id): return "api/v1/bookings/\(id)/decline"
        default: return ""
        }
    }
    
    static func offerPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .offersList, .offerCreate: return "api/v1/offers"
        case .offerDetail(let id): return "api/v1/offers/\(id)"
        case .offerUpdate(let id): return "api/v1/offers/\(id)"
        case .offerClose(let id): return "api/v1/offers/\(id)/close"
        case .offerDelete(let id): return "api/v1/offers/\(id)"
        default: return ""
        }
    }
    
    static func searchPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .searchProviders: return "api/v1/search/providers"
        case .searchOffers: return "api/v1/search/offers"
        default: return ""
        }
    }
    
    static func applicationPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .offerApplications(let id): return "api/v1/offers/\(id)/applications"
        case .offerApply(let id): return "api/v1/offers/\(id)/apply"
        case .applicationWithdraw(let id): return "api/v1/applications/\(id)/withdraw"
        case .applicationAccept(let id): return "api/v1/applications/\(id)/accept"
        case .applicationRefuse(let id): return "api/v1/applications/\(id)/refuse"
        default: return ""
        }
    }
    
    static func vatPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .vatValidate(let number): return "api/v1/utils/vat/validate?number=\(number)"
        default: return ""
        }
    }
    
    static func catalogPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .cities: return "api/v1/cities"
        case .serviceCategories: return "api/v1/service-categories"
        default: return ""
        }
    }
    
    static func mediaPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .mediaUpload: return "api/v1/media/upload"
        case .mediaDelete(let id): return "api/v1/media/\(id)"
        default: return ""
        }
    }
    
    static func notificationPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .notificationsList: return "api/v1/notifications"
        case .notificationRead(let id): return "api/v1/notifications/\(id)/read"
        case .notificationSubscribe(let topic): return "api/v1/notifications/subscribe?topic=\(topic)"
        default: return ""
        }
    }

    static func productsPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .products: return "api/v1/products"
        case .productsRecommended: return "api/v1/products/recommended"
        case .productClick(let id): return "api/v1/products/\(id)/click"
        default: return ""
        }
    }

    static func taxesPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .taxesSummary:
            return "api/v1/taxes/summary"
        case .taxesDocuments:
            return "api/v1/taxes/documents"
        case .taxesDownload(let id):
            return "api/v1/taxes/documents/\(id)/download"
        default:
            return ""
        }
    }
}
