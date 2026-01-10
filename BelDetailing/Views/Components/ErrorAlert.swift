//
//  ErrorAlert.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

/// Alert cohérent pour les erreurs avec design Uber-like
struct ErrorAlert {
    static func show(
        title: String,
        message: String,
        primaryAction: String = "OK",
        primaryActionHandler: (() -> Void)? = nil,
        secondaryAction: String? = nil,
        secondaryActionHandler: (() -> Void)? = nil
    ) {
        // Utiliser Alert standard de SwiftUI
        // Cette fonction sera utilisée avec .alert modifier
    }
}

/// Modifier pour afficher des alerts d'erreur cohérents
struct ErrorAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    var primaryAction: String = "OK"
    var primaryActionHandler: (() -> Void)? = nil
    var secondaryAction: String? = nil
    var secondaryActionHandler: (() -> Void)? = nil
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                if let secondaryAction = secondaryAction, let handler = secondaryActionHandler {
                    Button(secondaryAction, role: .cancel) {
                        handler()
                    }
                    Button(primaryAction) {
                        primaryActionHandler?()
                    }
                } else {
                    Button(primaryAction) {
                        primaryActionHandler?()
                    }
                }
            } message: {
                Text(message)
            }
    }
}

extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryAction: String = "OK",
        primaryActionHandler: (() -> Void)? = nil,
        secondaryAction: String? = nil,
        secondaryActionHandler: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryAction: primaryAction,
            primaryActionHandler: primaryActionHandler,
            secondaryAction: secondaryAction,
            secondaryActionHandler: secondaryActionHandler
        ))
    }
}

/// Variantes spécialisées pour différents types d'erreurs
extension ErrorAlertModifier {
    /// Alert pour paiement échoué
    static func paymentFailed(
        isPresented: Binding<Bool>,
        onRetry: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> ErrorAlertModifier {
        ErrorAlertModifier(
            isPresented: isPresented,
            title: R.string.localizable.errorPaymentFailedTitle(),
            message: R.string.localizable.errorPaymentFailedMessage(),
            primaryAction: R.string.localizable.commonRetry(),
            primaryActionHandler: onRetry,
            secondaryAction: onCancel != nil ? R.string.localizable.commonCancel() : nil,
            secondaryActionHandler: onCancel
        )
    }
    
    /// Alert pour booking annulé
    static func bookingCancelled(
        isPresented: Binding<Bool>,
        message: String,
        onOK: (() -> Void)? = nil
    ) -> ErrorAlertModifier {
        ErrorAlertModifier(
            isPresented: isPresented,
            title: R.string.localizable.errorBookingCancelledTitle(),
            message: message,
            primaryAction: "OK",
            primaryActionHandler: onOK
        )
    }
}
