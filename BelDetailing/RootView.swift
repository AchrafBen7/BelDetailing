//
//  RootView.swift
//  BelDetailing
//
//
//  RootView.swift
//  BelDetailing
//

import SwiftUI

struct RootView: View {
  @State private var path: [String] = []
  let engine: Engine

  var body: some View {
    NavigationStack(path: $path) {

      // === PAGE D’ACCUEIL : Onboarding ===
      OnboardingView(onFinish: {
        path.append("welcome")
      })

      .navigationDestination(for: String.self) { route in
        switch route {

        // === PAGE WELCOME ===
        case "welcome":
          WelcomeView(
            onStart: { path.append("signupRole") },
            onLogin: { path.append("login") }
          )
          .navigationBarBackButtonHidden(true)
          .toolbar {
            ToolbarItem(placement: .topBarLeading) { EmptyView() }
          }

        // === PAGE LOGIN ===
        case "login":
          LoginView(
            onBack: { path.removeLast() },
            onApple: { print("Apple login") },
            onGoogle: { print("Google login") },
            onEmail: { path.append("loginEmail") }, // ← redirection ici
            onShowTerms: { print("Show terms") },
            onShowPrivacy: { print("Show privacy") }
          )
          .navigationBarBackButtonHidden(true)

        // === PAGE LOGIN PAR EMAIL ===
        case "loginEmail":
          EmailLoginView(
            onBack: { path.removeLast() },
            onCreateAccount: { path.append("signupRole") } // ✅ redirection
          )
          .navigationBarBackButtonHidden(true)
        // === PAGE SÉLECTION DE RÔLE ===
        case "signupRole":
          SignupRoleSelectionView(engine: engine) { selectedRole in
            path.append(selectedRole.rawValue)
          }

        // === FORMULAIRES SELON LE RÔLE ===
        case UserRole.customer.rawValue:
          SignupFormView(
            role: .customer,
            onBack: { path.removeLast() },
            onSubmit: { print("Register particulier") }
          )

        case UserRole.company.rawValue:
          SignupFormView(
            role: .company,
            onBack: { path.removeLast() },
            onSubmit: { print("Register société") }
          )

        case UserRole.provider.rawValue:
          SignupFormView(
            role: .provider,
            onBack: { path.removeLast() },
            onSubmit: { print("Register prestataire") }
          )

        // === PAR DÉFAUT ===
        default:
          EmptyView()
        }
      }
    }
  }
}
