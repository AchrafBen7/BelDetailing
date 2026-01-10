//
//  AuthFlowView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 15/11/2025.
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case signupRole
    case signupCustomer
    case signupCompany
    case signupProvider
    case verifyEmail
}

struct AuthFlowView: View {
    let engine: Engine
    @Binding var isLoggedIn: Bool
    
    @State private var path: [AuthRoute] = []
    @State private var showVerify = false
    @State private var verifyEmailTemp = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onStart: { path.append(.signupRole) },
                onLogin: { path.append(.login) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                    
                case .login:
                    LoginScreen(
                        engine: engine,
                        onLoginSuccess: {
                            isLoggedIn = true
                            path = []
                        },
                        onSignup: {
                            path.append(.signupRole)
                        }
                    )
                    
                case .signupRole:
                    SignupRoleSelectionView(engine: engine) { selectedRole in
                        switch selectedRole {
                        case .customer: path.append(.signupCustomer)
                        case .company:  path.append(.signupCompany)
                        case .provider: path.append(.signupProvider)
                        }
                    }
                    
                case .signupCustomer:
                    SignupFormView(
                        role: .customer,
                        engine: engine,
                        onBack: { path.removeLast() },
                        onSuccess: { email in
                            // 🔥 Afficher la page de vérification d'email
                            let emailLowercased = email.lowercased().trimmingCharacters(in: .whitespaces)
                            print("🔍 [AUTH] Setting verifyEmailTemp to: '\(emailLowercased)'")
                            
                            // Mettre à jour l'email AVANT d'afficher le fullScreenCover
                            verifyEmailTemp = emailLowercased
                            
                            // Forcer la mise à jour du state avec Task
                            Task { @MainActor in
                                // Attendre que le state soit mis à jour
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
                                print("🔍 [AUTH] About to show verify screen, verifyEmailTemp: '\(verifyEmailTemp)'")
                                showVerify = true
                            }
                        },
                        onLogin: { path = [.login] }
                    )
                    
                case .signupCompany:
                    SignupFormView(
                        role: .company,
                        engine: engine,
                        onBack: { path.removeLast() },
                        onSuccess: { email in
                            // 🔥 Afficher la page de vérification d'email
                            let emailLowercased = email.lowercased().trimmingCharacters(in: .whitespaces)
                            print("🔍 [AUTH] Setting verifyEmailTemp to: '\(emailLowercased)'")
                            
                            // Mettre à jour l'email AVANT d'afficher le fullScreenCover
                            verifyEmailTemp = emailLowercased
                            
                            // Forcer la mise à jour du state avec Task
                            Task { @MainActor in
                                // Attendre que le state soit mis à jour
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
                                print("🔍 [AUTH] About to show verify screen, verifyEmailTemp: '\(verifyEmailTemp)'")
                                showVerify = true
                            }
                        },
                        onLogin: { path = [.login] }
                    )
                    
                case .signupProvider:
                    SignupFormView(
                        role: .provider,
                        engine: engine,
                        onBack: { path.removeLast() },
                        onSuccess: { email in
                            // 🔥 Afficher la page de vérification d'email
                            let emailLowercased = email.lowercased().trimmingCharacters(in: .whitespaces)
                            print("🔍 [AUTH] Setting verifyEmailTemp to: '\(emailLowercased)'")
                            
                            // Mettre à jour l'email AVANT d'afficher le fullScreenCover
                            verifyEmailTemp = emailLowercased
                            
                            // Forcer la mise à jour du state avec Task
                            Task { @MainActor in
                                // Attendre que le state soit mis à jour
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
                                print("🔍 [AUTH] About to show verify screen, verifyEmailTemp: '\(verifyEmailTemp)'")
                                showVerify = true
                            }
                        },
                        onLogin: { path = [.login] }
                    )
                    
                case .verifyEmail:
                    VerifyEmailView(
                        email: verifyEmailTemp,
                        engine: engine,
                        onBackToLogin: { path = [.login] },
                        onResendEmail: {
                            try? await engine.userService.resendConfirmationEmail(email: verifyEmailTemp)
                        },
                        onVerificationSuccess: {
                            // Vérification réussie, rediriger vers le login
                            path = [.login]
                        },
                        onSkipVerification: {
                            path = [.login]
                        }
                    )
                    
                }
            }
        }
        .fullScreenCover(isPresented: $showVerify) {
            VerifyEmailViewWrapper(
                email: verifyEmailTemp,
                engine: engine,
                onBackToLogin: {
                    showVerify = false
                    path = [.login]
                },
                onResendEmail: {
                    try? await engine.userService.resendConfirmationEmail(email: verifyEmailTemp)
                },
                onVerificationSuccess: {
                    showVerify = false
                    path = [.login]
                },
                onSkipVerification: {
                    showVerify = false
                    path = [.login]
                }
            )
        }
    }
}
