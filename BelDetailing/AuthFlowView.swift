//
//  AuthFlowView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 15/11/2025.
//

import SwiftUI

struct AuthFlowView: View {
    let engine: Engine

    @Binding var hasSeenOnboarding: Bool
    @Binding var isLoggedIn: Bool

    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {

            // 🔹 Start altijd met Onboarding
            OnboardingView(onFinish: {
                hasSeenOnboarding = true
                path = ["welcome"]
            })
            .navigationDestination(for: String.self) { route in
                switch route {

                case "welcome":
                    WelcomeView(
                        onStart: { path.append("signupRole") },
                        onLogin: { path.append("login") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "login":
                    LoginView(
                        onBack: { path.removeLast() },
                        onApple: {
                            // Mock Apple login
                            StorageManager.shared.setLoggedIn(true)
                            isLoggedIn = true
                        },
                        onGoogle: {
                            // Mock Google login
                            StorageManager.shared.setLoggedIn(true)
                            isLoggedIn = true
                        },
                        onEmail: {
                            path.append("loginEmail")
                        },
                        onShowTerms: { print("Show terms") },
                        onShowPrivacy: { print("Show privacy") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "loginEmail":
                    EmailLoginView(
                        onBack: { path.removeLast() },
                        onCreateAccount: { path.append("signupRole") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "signupRole":
                    SignupRoleSelectionView(engine: engine) { selectedRole in
                        path.append(selectedRole.rawValue)
                    }

                case UserRole.customer.rawValue:
                    SignupFormView(
                        role: .customer,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            StorageManager.shared.setLoggedIn(true)
                            isLoggedIn = true
                        }
                    )

                case UserRole.company.rawValue:
                    SignupFormView(
                        role: .company,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            StorageManager.shared.setLoggedIn(true)
                            isLoggedIn = true
                        }
                    )

                case UserRole.provider.rawValue:
                    SignupFormView(
                        role: .provider,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            StorageManager.shared.setLoggedIn(true)
                            isLoggedIn = true
                        }
                    )

                default:
                    EmptyView()
                }
            }
        }
    }
}
