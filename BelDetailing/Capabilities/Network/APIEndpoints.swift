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
    case verifyEmail
    case resendVerificationEmail
    
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
    case providerServiceCreate            // ⬅️ création d’un service (POST /providers/services)
    case providerMeUpdate                 // ⬅️ NOUVEAU: PATCH /api/v1/providers/me
    
    // Bookings
    case bookingsList(scope: String?, status: String?)
    case bookingCreate
    case bookingUpdate(id: String)
    case bookingCancel(id: String)
    case bookingConfirm(id: String)
    case bookingDecline(id: String)
    case bookingStartService(id: String)  // Start service (changes status to started/in_progress)
    case bookingReportNoShow(id: String)  // Report no-show (client absent)
    case bookingUpdateProgress(id: String)  // Update service progress (step completion)
    case bookingCompleteService(id: String)  // Mark service as completed
    case bookingCounterPropose(id: String)  // Provider proposes alternative date/time
    case bookingAcceptCounterProposal(id: String)  // Customer accepts counter-proposal
    case bookingRefuseCounterProposal(id: String)  // Customer refuses counter-proposal
    case bookingCleanupExpired  // DELETE /api/v1/bookings/expired - Supprime les bookings pending > 6h
    
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
    case vatLookup  // POST /api/v1/vat/lookup - Recherche complète avec pré-remplissage
    
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
    case productDetail(id: String)
    
    // Orders
    case ordersList
    case orderCreate
    case orderDetail(id: String)
    case orderCancel(id: String)

    // Taxes
    case taxesSummary
    case taxesDocuments
    case taxesDownload(id: String)

    // Stripe Connect (Provider payouts)
    case stripeConnectCreateAccount
    case stripeConnectOnboardingLink
    case stripeConnectAccountStatus
    case stripeConnectPayoutsSummary
    
    // Chat
    case chatConversationsList
    case chatConversationDetail(id: String)
    case chatConversationCreate
    case chatMessages(conversationId: String)
    case chatSendMessage(conversationId: String)
    case chatMarkAsRead(conversationId: String)
    
    // Google Review Prompts
    case reviewPromptCreate
    case reviewPromptGet(bookingId: String)
    case reviewPromptTrackRating(id: String)
    case reviewPromptGoogleRedirect(id: String)
    case reviewPromptDismiss(id: String)
    
    // Provider Portfolio
    case providerPortfolio(providerId: String)
    case providerPortfolioAdd
    case providerPortfolioDelete(id: String)
    case providerPortfolioUpdate(id: String)
    
    // Service Photos
    case servicePhotos(serviceId: String)
    case servicePhotoAdd(serviceId: String)
    case servicePhotoDelete(serviceId: String, photoId: String)
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
        case .register, .login, .refresh, .profile, .updateProfile, .loginApple, .loginGoogle, .logout,
             .verifyEmail, .resendVerificationEmail:
            return authPath(for: endPoint)

        case .providersList, .providerDetail, .providerReviews, .providerServices, .providerStats, .providerReviewCreate,
             .providerMyStats, .providerMyServices, .providerMyReviews, .providerServiceCreate, .providerMeUpdate,
             .providerPortfolio, .providerPortfolioAdd, .providerPortfolioDelete, .providerPortfolioUpdate:
            return providerPath(for: endPoint)

        case .bookingsList, .bookingCreate, .bookingUpdate, .bookingCancel, .bookingConfirm, .bookingDecline,
             .bookingStartService, .bookingReportNoShow, .bookingUpdateProgress, .bookingCompleteService,
             .bookingCounterPropose, .bookingAcceptCounterProposal, .bookingRefuseCounterProposal,
             .bookingCleanupExpired:
            return bookingPath(for: endPoint)

        case .offersList, .offerDetail, .offerCreate, .offerUpdate, .offerClose, .offerDelete:
            return offerPath(for: endPoint)

        case .searchProviders, .searchOffers:
            return searchPath(for: endPoint)

        case .offerApplications, .offerApply, .applicationWithdraw, .applicationAccept, .applicationRefuse:
            return applicationPath(for: endPoint)

        case .vatValidate, .vatLookup:
            return vatPath(for: endPoint)

        case .cities, .serviceCategories:
            return catalogPath(for: endPoint)

        case .mediaUpload, .mediaDelete:
            return mediaPath(for: endPoint)
            
        case .servicePhotos, .servicePhotoAdd, .servicePhotoDelete:
            return servicePhotoPath(for: endPoint)

        case .notificationsList, .notificationRead, .notificationSubscribe:
            return notificationPath(for: endPoint)

        case .paymentIntent, .paymentCapture, .paymentRefund, .paymentSetupIntent, .paymentMethods, .paymentTransactions, .paymentMethodDelete:
            return paymentsPath(for: endPoint)

        case .products, .productsRecommended, .productClick, .productDetail:
            return productsPath(for: endPoint)
            
        case .ordersList, .orderCreate, .orderDetail, .orderCancel:
            return ordersPath(for: endPoint)

        case .taxesSummary, .taxesDocuments, .taxesDownload:
            return taxesPath(for: endPoint)

        case .stripeConnectCreateAccount, .stripeConnectOnboardingLink, .stripeConnectAccountStatus, .stripeConnectPayoutsSummary:
            return stripeConnectPath(for: endPoint)
            
        case .chatConversationsList, .chatConversationDetail, .chatConversationCreate,
             .chatMessages, .chatSendMessage, .chatMarkAsRead:
            return chatPath(for: endPoint)
            
        case .reviewPromptCreate, .reviewPromptGet, .reviewPromptTrackRating,
             .reviewPromptGoogleRedirect, .reviewPromptDismiss:
            return reviewPromptPath(for: endPoint)
        }
    }

    static func method(for endPoint: APIEndPoint) -> HTTPVerb {
        switch endPoint {
        case .register, .login, .refresh, .loginApple, .loginGoogle, .logout, .providerReviewCreate, .bookingCreate, .bookingCancel,
             .bookingConfirm, .bookingDecline, .bookingStartService, .bookingReportNoShow, .bookingUpdateProgress, .bookingCompleteService,
             .bookingCounterPropose, .bookingAcceptCounterProposal, .bookingRefuseCounterProposal,
             .offerCreate, .offerClose, .offerApply,
             .applicationWithdraw, .applicationAccept, .applicationRefuse,
             .notificationSubscribe, .paymentIntent, .paymentCapture, .paymentRefund, .mediaUpload,
             .productClick, .orderCreate,
             .paymentSetupIntent,
             .providerServiceCreate,
             .stripeConnectCreateAccount,          // POST
             .stripeConnectOnboardingLink,         // POST
             .verifyEmail, .resendVerificationEmail,  // POST
             .vatLookup,  // POST
             .chatConversationCreate, .chatSendMessage, .chatMarkAsRead,  // POST
             .reviewPromptCreate, .reviewPromptTrackRating, .reviewPromptGoogleRedirect, .reviewPromptDismiss,  // POST
             .providerPortfolioAdd, .servicePhotoAdd:  // POST
            return .post

        case .updateProfile, .bookingUpdate, .offerUpdate, .notificationRead,
             .providerMeUpdate, .providerPortfolioUpdate:  // PATCH
            return .patch

        case .providerDetail, .providersList, .providerReviews, .providerServices,
             .providerStats, .providerMyStats, .providerMyServices, .providerMyReviews,
             .offersList, .offerDetail, .bookingsList,
             .cities, .serviceCategories, .searchProviders, .searchOffers,
             .products, .productsRecommended, .productDetail, .ordersList, .orderDetail,
             .offerApplications, .profile, .notificationsList, .vatValidate,
             .paymentMethods, .paymentTransactions,
             .taxesSummary, .taxesDocuments, .taxesDownload,
             .stripeConnectAccountStatus,          // GET
             .stripeConnectPayoutsSummary,         // GET
             .chatConversationsList, .chatConversationDetail, .chatMessages,  // GET
             .reviewPromptGet, .providerPortfolio, .servicePhotos:  // GET
            return .get

        case .offerDelete, .mediaDelete, .paymentMethodDelete, .orderCancel, .bookingCleanupExpired,
             .providerPortfolioDelete, .servicePhotoDelete:
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
        case .verifyEmail: return "api/v1/auth/verify-email"
        case .resendVerificationEmail: return "api/v1/auth/resend-verification-email"
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
        case .providerServiceCreate: return "api/v1/providers/services"
        case .providerMeUpdate: return "api/v1/providers/me"
        case .providerPortfolio(let id): return "api/v1/providers/\(id)/portfolio"
        case .providerPortfolioAdd: return "api/v1/providers/me/portfolio"
        case .providerPortfolioDelete(let id): return "api/v1/providers/me/portfolio/\(id)"
        case .providerPortfolioUpdate(let id): return "api/v1/providers/me/portfolio/\(id)"
        default: return ""
        }
    }
    
    static func servicePhotoPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .servicePhotos(let serviceId): return "api/v1/services/\(serviceId)/photos"
        case .servicePhotoAdd(let serviceId): return "api/v1/services/\(serviceId)/photos"
        case .servicePhotoDelete(let serviceId, let photoId): return "api/v1/services/\(serviceId)/photos/\(photoId)"
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
        case .bookingStartService(let id): return "api/v1/bookings/\(id)/start"
        case .bookingReportNoShow(let id): return "api/v1/bookings/\(id)/no-show"
        case .bookingUpdateProgress(let id): return "api/v1/bookings/\(id)/progress"
        case .bookingCompleteService(let id): return "api/v1/bookings/\(id)/complete"
        case .bookingCounterPropose(let id): return "api/v1/bookings/\(id)/counter-propose"
        case .bookingAcceptCounterProposal(let id): return "api/v1/bookings/\(id)/accept-counter-proposal"
        case .bookingRefuseCounterProposal(let id): return "api/v1/bookings/\(id)/refuse-counter-proposal"
        case .bookingCleanupExpired: return "api/v1/bookings/expired"
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
        case .vatLookup: return "api/v1/vat/lookup"
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
        case .productDetail(let id): return "api/v1/products/\(id)"
        default: return ""
        }
    }
    
    static func ordersPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .ordersList: return "api/v1/orders"
        case .orderCreate: return "api/v1/orders"
        case .orderDetail(let id): return "api/v1/orders/\(id)"
        case .orderCancel(let id): return "api/v1/orders/\(id)/cancel"
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

    static func stripeConnectPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .stripeConnectCreateAccount:
            return "api/v1/stripe/connect/account"
        case .stripeConnectOnboardingLink:
            return "api/v1/stripe/connect/onboarding-link"
        case .stripeConnectAccountStatus:
            return "api/v1/stripe/connect/account-status"
        case .stripeConnectPayoutsSummary:
            return "api/v1/stripe/connect/payouts-summary"
        default:
            return ""
        }
    }
    
    static func chatPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .chatConversationsList:
            return "api/v1/chat/conversations"
        case .chatConversationDetail(let id):
            return "api/v1/chat/conversations/\(id)"
        case .chatConversationCreate:
            return "api/v1/chat/conversations"
        case .chatMessages(let conversationId):
            return "api/v1/chat/conversations/\(conversationId)/messages"
        case .chatSendMessage(let conversationId):
            return "api/v1/chat/conversations/\(conversationId)/messages"
        case .chatMarkAsRead(let conversationId):
            return "api/v1/chat/conversations/\(conversationId)/read"
        default:
            return ""
        }
    }
    
    static func reviewPromptPath(for endPoint: APIEndPoint) -> String {
        switch endPoint {
        case .reviewPromptCreate:
            return "api/v1/reviews/prompt"
        case .reviewPromptGet(let bookingId):
            return "api/v1/reviews/prompt/\(bookingId)"
        case .reviewPromptTrackRating(let id):
            return "api/v1/reviews/prompt/\(id)/rating"
        case .reviewPromptGoogleRedirect(let id):
            return "api/v1/reviews/prompt/\(id)/google-redirect"
        case .reviewPromptDismiss(let id):
            return "api/v1/reviews/prompt/\(id)/dismiss"
        default:
            return ""
        }
    }
}
