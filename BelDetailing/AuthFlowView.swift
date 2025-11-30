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
}

struct AuthFlowView: View {
    let engine: Engine
    @Binding var isLoggedIn: Bool

    @State private var path: [AuthRoute] = []

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
                        onBack: { path.removeLast() },
                        onSubmit: {
                            isLoggedIn = true
                            path = []
                        }
                    )

                case .signupCompany:
                    SignupFormView(
                        role: .company,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            isLoggedIn = true
                            path = []
                        }
                    )

                case .signupProvider:
                    SignupFormView(
                        role: .provider,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            isLoggedIn = true
                            path = []
                        }
                    )
                }
            }
        }
    }
}
