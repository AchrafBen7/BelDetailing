//
//  ErrorHandlingSystem.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Système complet de gestion d'erreurs
//

import SwiftUI
import Combine
import RswiftResources

// MARK: - Error Types

enum AppError: LocalizedError {
    // Network Errors
    case networkUnavailable
    case networkTimeout
    case serverError(Int)
    case requestCancelled

    // Authentication Errors
    case invalidCredentials
    case sessionExpired
    case unauthorized
    case emailNotVerified

    // Validation Errors
    case invalidEmail
    case invalidPhone
    case invalidVAT
    case invalidInput(String)
    case missingRequiredField(String)

    // Booking Errors
    case bookingNotFound
    case bookingAlreadyCancelled
    case bookingTooLate
    case bookingConflict
    case bookingCreationFailed
    case bookingUpdateFailed
    case bookingCancellationFailed

    // Payment Errors
    case paymentFailed
    case paymentCancelled
    case paymentIntentFailed
    case refundFailed
    case insufficientFunds
    case cardDeclined
    case paymentMethodInvalid

    // Service Errors
    case serviceNotFound
    case serviceCreationFailed
    case serviceUpdateFailed
    case serviceDeletionFailed

    // Provider Errors
    case providerNotFound
    case providerProfileIncomplete
    case stripeAccountNotReady
    case stripeOnboardingIncomplete

    // Upload Errors
    case imageUploadFailed
    case imageTooLarge
    case invalidImageFormat
    case uploadCancelled

    // Location Errors
    case locationPermissionDenied
    case locationUnavailable
    case geocodingFailed

    // Chat Errors
    case conversationNotFound
    case messageSendFailed
    case messageLoadFailed

    // Review Errors
    case reviewCreationFailed
    case reviewNotFound
    case alreadyReviewed

    // Generic Errors
    case unknownError
    case operationFailed(String)

    // MARK: - Localized Messages

    var errorTitle: String {
        switch self {
        case .networkUnavailable, .networkTimeout, .requestCancelled:
            return R.string.localizable.errorNetworkTitle()
        case .serverError:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorServerTitle plus tard
        case .invalidCredentials, .sessionExpired, .unauthorized, .emailNotVerified:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorAuthTitle plus tard
        case .invalidEmail, .invalidPhone, .invalidVAT, .invalidInput, .missingRequiredField:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorValidationTitle plus tard
        case .bookingNotFound, .bookingAlreadyCancelled, .bookingTooLate, .bookingConflict,
             .bookingCreationFailed, .bookingUpdateFailed, .bookingCancellationFailed:
            return R.string.localizable.errorBookingTitle()
        case .paymentFailed, .paymentCancelled, .paymentIntentFailed, .refundFailed,
             .insufficientFunds, .cardDeclined, .paymentMethodInvalid:
            return R.string.localizable.errorPaymentFailedTitle()
        case .serviceNotFound, .serviceCreationFailed, .serviceUpdateFailed, .serviceDeletionFailed:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorServiceTitle plus tard
        case .providerNotFound, .providerProfileIncomplete, .stripeAccountNotReady, .stripeOnboardingIncomplete:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorProviderTitle plus tard
        case .imageUploadFailed, .imageTooLarge, .invalidImageFormat, .uploadCancelled:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorUploadTitle plus tard
        case .locationPermissionDenied, .locationUnavailable, .geocodingFailed:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorLocationTitle plus tard
        case .conversationNotFound, .messageSendFailed, .messageLoadFailed:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorChatTitle plus tard
        case .reviewCreationFailed, .reviewNotFound, .alreadyReviewed:
            return R.string.localizable.errorGenericTitle() // Fallback - ajouter errorReviewTitle plus tard
        case .unknownError, .operationFailed:
            return R.string.localizable.errorGenericTitle()
        }
    }

    var errorMessage: String {
        switch self {
        case .networkUnavailable:
            return R.string.localizable.errorNetworkMessage() // Utiliser la clé existante
        case .networkTimeout:
            return R.string.localizable.errorNetworkMessage() // Fallback - ajouter errorNetworkTimeoutMessage plus tard
        case .requestCancelled:
            return R.string.localizable.errorNetworkMessage() // Fallback
        case .serverError(let code):
            return R.string.localizable.errorGenericMessage() // Fallback - ajouter errorServerMessage plus tard
        case .invalidCredentials:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .sessionExpired:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .unauthorized:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .emailNotVerified:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .invalidEmail:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .invalidPhone:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .invalidVAT:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .invalidInput(let field):
            return "Champ invalide : \(field)" // Fallback temporaire
        case .missingRequiredField(let field):
            return "Champ requis manquant : \(field)" // Fallback temporaire
        case .bookingNotFound:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .bookingAlreadyCancelled:
            return R.string.localizable.errorBookingCancelledMessage() // Utiliser la clé existante
        case .bookingTooLate:
            return R.string.localizable.bookingTooLateMessage() // Utiliser la clé existante
        case .bookingConflict:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .bookingCreationFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .bookingUpdateFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .bookingCancellationFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .paymentFailed:
            return R.string.localizable.errorPaymentFailedMessage() // Utiliser la clé existante
        case .paymentCancelled:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .paymentIntentFailed:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .refundFailed:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .insufficientFunds:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .cardDeclined:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .paymentMethodInvalid:
            return R.string.localizable.errorPaymentFailedMessage() // Fallback
        case .serviceNotFound:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .serviceCreationFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .serviceUpdateFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .serviceDeletionFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .providerNotFound:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .providerProfileIncomplete:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .stripeAccountNotReady:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .stripeOnboardingIncomplete:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .imageUploadFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .imageTooLarge:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .invalidImageFormat:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .uploadCancelled:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .locationPermissionDenied:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .locationUnavailable:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .geocodingFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .conversationNotFound:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .messageSendFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .messageLoadFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .reviewCreationFailed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .reviewNotFound:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .alreadyReviewed:
            return R.string.localizable.errorGenericMessage() // Fallback
        case .unknownError:
            return R.string.localizable.errorGenericMessage()
        case .operationFailed(let operation):
            return "Échec de l'opération : \(operation)" // Fallback temporaire
        }
    }

    var errorIcon: String {
        switch self {
        case .networkUnavailable, .networkTimeout, .requestCancelled:
            return "wifi.exclamationmark"
        case .serverError:
            return "server.rack"
        case .invalidCredentials, .sessionExpired, .unauthorized, .emailNotVerified:
            return "lock.shield.fill"
        case .invalidEmail, .invalidPhone, .invalidVAT, .invalidInput, .missingRequiredField:
            return "exclamationmark.circle.fill"
        case .bookingNotFound, .bookingAlreadyCancelled, .bookingTooLate, .bookingConflict,
             .bookingCreationFailed, .bookingUpdateFailed, .bookingCancellationFailed:
            return "calendar.badge.exclamationmark"
        case .paymentFailed, .paymentCancelled, .paymentIntentFailed, .refundFailed,
             .insufficientFunds, .cardDeclined, .paymentMethodInvalid:
            return "creditcard.trianglebadge.exclamationmark.fill"
        case .serviceNotFound, .serviceCreationFailed, .serviceUpdateFailed, .serviceDeletionFailed:
            return "wrench.and.screwdriver.fill"
        case .providerNotFound, .providerProfileIncomplete, .stripeAccountNotReady, .stripeOnboardingIncomplete:
            return "person.crop.circle.badge.exclamationmark.fill"
        case .imageUploadFailed, .imageTooLarge, .invalidImageFormat, .uploadCancelled:
            return "photo.badge.exclamationmark.fill"
        case .locationPermissionDenied, .locationUnavailable, .geocodingFailed:
            return "location.slash.fill"
        case .conversationNotFound, .messageSendFailed, .messageLoadFailed:
            return "message.badge.filled.fill"
        case .reviewCreationFailed, .reviewNotFound, .alreadyReviewed:
            return "star.slash.fill"
        case .unknownError, .operationFailed:
            return "exclamationmark.triangle.fill"
        }
    }

    var errorColor: Color {
        switch self {
        case .networkUnavailable, .networkTimeout, .requestCancelled:
            return DesignSystem.Colors.warning
        case .serverError:
            return DesignSystem.Colors.error
        case .invalidCredentials, .sessionExpired, .unauthorized, .emailNotVerified:
            return DesignSystem.Colors.error
        case .invalidEmail, .invalidPhone, .invalidVAT, .invalidInput, .missingRequiredField:
            return DesignSystem.Colors.warning
        case .bookingNotFound, .bookingAlreadyCancelled, .bookingTooLate, .bookingConflict,
             .bookingCreationFailed, .bookingUpdateFailed, .bookingCancellationFailed:
            return DesignSystem.Colors.error
        case .paymentFailed, .paymentCancelled, .paymentIntentFailed, .refundFailed,
             .insufficientFunds, .cardDeclined, .paymentMethodInvalid:
            return DesignSystem.Colors.error
        case .serviceNotFound, .serviceCreationFailed, .serviceUpdateFailed, .serviceDeletionFailed:
            return DesignSystem.Colors.error
        case .providerNotFound, .providerProfileIncomplete, .stripeAccountNotReady, .stripeOnboardingIncomplete:
            return DesignSystem.Colors.warning
        case .imageUploadFailed, .imageTooLarge, .invalidImageFormat, .uploadCancelled:
            return DesignSystem.Colors.warning
        case .locationPermissionDenied, .locationUnavailable, .geocodingFailed:
            return DesignSystem.Colors.warning
        case .conversationNotFound, .messageSendFailed, .messageLoadFailed:
            return DesignSystem.Colors.warning
        case .reviewCreationFailed, .reviewNotFound, .alreadyReviewed:
            return DesignSystem.Colors.warning
        case .unknownError, .operationFailed:
            return DesignSystem.Colors.error
        }
    }

    var canRetry: Bool {
        switch self {
        case .networkUnavailable, .networkTimeout, .requestCancelled,
             .bookingCreationFailed, .bookingUpdateFailed, .bookingCancellationFailed,
             .paymentFailed, .paymentIntentFailed, .refundFailed,
             .serviceCreationFailed, .serviceUpdateFailed, .serviceDeletionFailed,
             .imageUploadFailed, .messageSendFailed, .messageLoadFailed,
             .reviewCreationFailed, .operationFailed:
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Handler

class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError: Bool = false

    func handle(_ error: Error) {
        let appError = mapToAppError(error)
        currentError = appError
        showError = true
    }

    func handle(_ appError: AppError) {
        currentError = appError
        showError = true
    }

    func clear() {
        currentError = nil
        showError = false
    }

    private func mapToAppError(_ error: Error) -> AppError {
        if let apiError = error as? APIError {
            switch apiError {
            case .noNetwork:
                return .networkUnavailable
            case .serverError(let code):
                return .serverError(code)
            case .unauthorized:
                return .unauthorized
            case .decodingError:
                return .unknownError
            case .urlError:
                return .networkUnavailable
            case .unknownError:
                return .unknownError
            case .other(let underlyingError):
                if let nsError = underlyingError as NSError? {
                    if nsError.code == NSURLErrorTimedOut {
                        return .networkTimeout
                    } else if nsError.code == NSURLErrorCancelled {
                        return .requestCancelled
                    }
                }
                return .unknownError
            }
        }

        // Map other error types
        if let appError = error as? AppError {
            return appError
        }

        return .unknownError
    }
}

// MARK: - Error View Modifier

struct ErrorViewModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.errorTitle ?? R.string.localizable.errorGenericTitle(),
                isPresented: $errorHandler.showError
            ) {
                if let error = errorHandler.currentError, error.canRetry, let onRetry = onRetry {
                    Button(R.string.localizable.commonRetry()) {
                        onRetry()
                        errorHandler.clear()
                    }
                    Button(R.string.localizable.commonCancel(), role: .cancel) {
                        onDismiss?()
                        errorHandler.clear()
                    }
                } else {
                    Button("OK") {
                        onDismiss?()
                        errorHandler.clear()
                    }
                }
            } message: {
                Text(errorHandler.currentError?.errorMessage ?? R.string.localizable.errorGenericMessage())
            }
    }
}

extension View {
    func errorHandler(
        _ handler: ErrorHandler,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorViewModifier(
            errorHandler: handler,
            onRetry: onRetry,
            onDismiss: onDismiss
        ))
    }
}
