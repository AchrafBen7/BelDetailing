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
      OnboardingView(onFinish: {
        path.append("welcome")
      })
      .navigationDestination(for: String.self) { route in
        switch route {

        case "welcome":
          WelcomeView(
            onStart: { path.append("signupRole") },
            onLogin: { /* plus tard */ }
          )
          .navigationBarBackButtonHidden(true)
          .toolbar {
            ToolbarItem(placement: .topBarLeading) { EmptyView() }
          }

        case "signupRole":
          SignupRoleSelectionView(engine: engine) { selectedRole in
            path.append(selectedRole.rawValue)
          }

        case UserRole.customer.rawValue:
          SignupFormView(role: .customer, onBack: {
            path.removeLast()
          }, onSubmit: {
            print("Register particulier")
          })

        case UserRole.company.rawValue:
          SignupFormView(role: .company, onBack: {
            path.removeLast()
          }, onSubmit: {
            print("Register société")
          })

        case UserRole.provider.rawValue:
          SignupFormView(role: .provider, onBack: {
            path.removeLast()
          }, onSubmit: {
            print("Register prestataire")
          })

        default:
          EmptyView()
        }
      }
    }
  }
}
