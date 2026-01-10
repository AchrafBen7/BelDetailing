//
//  VerifyEmailViewWrapper.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct VerifyEmailViewWrapper: View {
    let email: String
    let engine: Engine
    let onBackToLogin: () -> Void
    let onResendEmail: () async -> Void
    let onVerificationSuccess: (() -> Void)?
    let onSkipVerification: (() -> Void)?
    
    var body: some View {
        if !email.isEmpty {
            VerifyEmailView(
                email: email,
                engine: engine,
                onBackToLogin: onBackToLogin,
                onResendEmail: onResendEmail,
                onVerificationSuccess: onVerificationSuccess,
                onSkipVerification: onSkipVerification
            )
            .onAppear {
                print("🔍 [AUTH] VerifyEmailView appeared with email: '\(email)'")
            }
        } else {
            // Fallback si l'email n'est pas disponible
            ZStack {
                // Background
                GeometryReader { geometry in
                    Image("launchImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .overlay(Color.black.opacity(0.65))
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Back button
                    HStack {
                        Button {
                            onBackToLogin()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Retour")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                            )
                        }
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Erreur: Email non disponible")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Impossible de récupérer l'email. Veuillez réessayer l'inscription.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            onBackToLogin()
                        } label: {
                            Text("Retour à la connexion")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                print("❌ [AUTH] ERROR: verifyEmailTemp is empty! Cannot show verification screen.")
            }
        }
    }
}

