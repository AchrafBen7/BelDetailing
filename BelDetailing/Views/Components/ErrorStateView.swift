//
//  ErrorStateView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//  Updated to use Design System
//

import SwiftUI
import RswiftResources

/// Vue d'état d'erreur réutilisable avec design Uber-like (Design System)
struct ErrorStateView: View {
    let title: String
    let message: String
    var systemIcon: String = "exclamationmark.triangle.fill"
    var iconColor: Color = DesignSystem.Colors.error
    
    /// Actions optionnelles
    var onRetry: (() -> Void)? = nil
    var primaryAction: (title: String, action: () -> Void)? = nil
    var secondaryAction: (title: String, action: () -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Icône
            Image(systemName: systemIcon)
                .font(.system(size: 56))
                .foregroundColor(iconColor)
                .frame(width: 100, height: 100)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            // Texte
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxl)
            }
            
            // Actions
            VStack(spacing: DesignSystem.Spacing.md) {
                if let primaryAction = primaryAction {
                    Button {
                        primaryAction.action()
                    } label: {
                        Text(primaryAction.title)
                            .font(DesignSystem.Typography.buttonCTA)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                } else if let onRetry = onRetry {
                    Button {
                        onRetry()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(R.string.localizable.commonRetry())
                        }
                        .font(DesignSystem.Typography.buttonCTA)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                }
                
                if let secondaryAction = secondaryAction {
                    Button {
                        secondaryAction.action()
                    } label: {
                        Text(secondaryAction.title)
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .stroke(DesignSystem.Colors.borderStrong, lineWidth: 1.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xxl)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
}

/// Variantes spécialisées pour différents types d'erreurs
extension ErrorStateView {
    /// Erreur de paiement
    static func paymentFailed(
        onRetry: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> ErrorStateView {
        ErrorStateView(
            title: R.string.localizable.errorPaymentFailedTitle(),
            message: R.string.localizable.errorPaymentFailedMessage(),
            systemIcon: "creditcard.trianglebadge.exclamationmark.fill",
            iconColor: .red,
            primaryAction: (R.string.localizable.commonRetry(), onRetry),
            secondaryAction: onCancel.map { (R.string.localizable.commonCancel(), $0) }
        )
    }
    
    /// Erreur de réseau
    static func networkError(
        onRetry: @escaping () -> Void
    ) -> ErrorStateView {
        ErrorStateView(
            title: R.string.localizable.errorNetworkTitle(),
            message: R.string.localizable.errorNetworkMessage(),
            systemIcon: "wifi.exclamationmark",
            iconColor: .orange,
            onRetry: onRetry
        )
    }
    
    /// Erreur de booking
    static func bookingError(
        message: String,
        onRetry: (() -> Void)? = nil
    ) -> ErrorStateView {
        ErrorStateView(
            title: R.string.localizable.errorBookingTitle(),
            message: message,
            systemIcon: "calendar.badge.exclamationmark",
            iconColor: .red,
            onRetry: onRetry
        )
    }
    
    /// Erreur générique
    static func generic(
        title: String,
        message: String,
        onRetry: (() -> Void)? = nil
    ) -> ErrorStateView {
        ErrorStateView(
            title: title,
            message: message,
            systemIcon: "exclamationmark.triangle.fill",
            iconColor: .red,
            onRetry: onRetry
        )
    }
}

