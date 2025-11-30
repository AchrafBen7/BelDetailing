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
    @State private var tempEmail: String = ""
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
                    LoginScreen(engine: engine, onLoginSuccess: {
                        isLoggedIn = true
                        path = []
                    })
                    
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
                            verifyEmailTemp = email.lowercased()
                            showVerify = true         // 🔥 OPEN FULLSCREEN HERE
                        },
                        
                        
                        onLogin: { path = [.login] }
                    )
                    
                case .signupCompany:
                    SignupFormView(
                        role: .company,
                        engine: engine,
                        onBack: { path.removeLast() },
                        onSuccess: { email in
                            verifyEmailTemp = email.lowercased()
                            showVerify = true         // 🔥 OPEN FULLSCREEN HERE
                        },
                        
                        
                        onLogin: { path = [.login] }
                    )
                    
                case .signupProvider:
                    SignupFormView(
                        role: .provider,
                        engine: engine,
                        onBack: { path.removeLast() },
                        onSuccess: { email in
                            verifyEmailTemp = email.lowercased()
                            showVerify = true         // 🔥 OPEN FULLSCREEN HERE
                        },
                        
                        onLogin: { path = [.login] }
                    )
                case .verifyEmail:
                    VerifyEmailView(
                        email: tempEmail,
                        onBackToLogin: { path = [.login] },
                        onResendEmail: { await engine.userService.resendConfirmationEmail(email: tempEmail) }
                    )
                    
                }
            }
            
        }
        .fullScreenCover(isPresented: $showVerify) {
            VerifyEmailView(
                email: verifyEmailTemp,
                onBackToLogin: {
                    showVerify = false
                    path = [.login]
                },
                onResendEmail: {
                    await engine.userService.resendConfirmationEmail(email: verifyEmailTemp)
                }
            )
        }

    }
}
