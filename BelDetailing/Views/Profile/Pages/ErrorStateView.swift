import SwiftUI
import RswiftResources

struct ErrorStateView: View {
    let title: String
    let message: String
    let systemIcon: String
    let primaryActionTitle: String?
    let primaryAction: (() -> Void)?
    let secondaryActionTitle: String?
    let secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                title: title,
                message: message,
                systemIcon: systemIcon,
                onRetry: primaryAction
            )
            if let secondaryActionTitle, let secondaryAction {
                Button(secondaryActionTitle) {
                    secondaryAction()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

extension ErrorStateView {
    // Network error with a retry action
    static func networkError(onRetry: @escaping () -> Void) -> some View {
        ErrorStateView(
            title: "Problème de connexion",
            message: "Vérifiez votre connexion internet et réessayez.",
            systemIcon: "wifi.exclamationmark",
            primaryActionTitle: "Réessayer",
            primaryAction: onRetry,
            secondaryActionTitle: nil,
            secondaryAction: nil
        )
    }

    // Payment failed with retry and cancel actions
    static func paymentFailed(onRetry: @escaping () -> Void, onCancel: @escaping () -> Void) -> some View {
        ErrorStateView(
            title: "Paiement échoué",
            message: "Une erreur est survenue lors du paiement. Vous pouvez réessayer ou annuler.",
            systemIcon: "xmark.octagon.fill",
            primaryActionTitle: "Réessayer",
            primaryAction: onRetry,
            secondaryActionTitle: "Annuler",
            secondaryAction: onCancel
        )
    }
}
