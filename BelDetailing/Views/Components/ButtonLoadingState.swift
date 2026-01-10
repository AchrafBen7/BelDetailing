//
//  ButtonLoadingState.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

/// Modifier pour ajouter un état de chargement aux boutons
struct ButtonLoadingModifier: ViewModifier {
    let isLoading: Bool
    let loadingText: String?
    
    func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1.0)
            .overlay(
                Group {
                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            if let loadingText = loadingText {
                                Text(loadingText)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            )
    }
}

extension View {
    /// Ajoute un état de chargement au bouton
    func buttonLoading(isLoading: Bool, loadingText: String? = nil) -> some View {
        modifier(ButtonLoadingModifier(isLoading: isLoading, loadingText: loadingText))
    }
}

/// Bouton avec état de chargement intégré
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let loadingText: String?
    let action: () -> Void
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                    if let loadingText = loadingText {
                        Text(loadingText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(foregroundColor)
                    }
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

