//
//  BelDetailingApp.swift
//  BelDetailing
//
//  Created by Achraf Benali on 04/11/2025.
//// BelDetailingApp.swift
///
import SwiftUI

@main
struct BelDetailingApp: App {
  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
  @AppStorage("forceWelcome") private var forceWelcome = true

  let engine = Engine(mock: true)
  @State private var showSignup = false

  var body: some Scene {
    WindowGroup {
      NavigationView {
        if forceWelcome || !hasSeenOnboarding {
          WelcomeView(
            onStart: { showSignup = true },
            onLogin: {
              // tu pourras y mettre plus tard la logique de login
            }
          )
          .background(
            NavigationLink(
              destination: SignupRoleSelectionView(engine: engine) { role in
                print("✅ rôle sélectionné :", role)
                // ici tu pourras enchaîner vers SignupFormView(role:)
              },
              isActive: $showSignup
            ) {
              EmptyView()
            }
            .hidden()
          )
        } else {
          MainTabView(engine: engine)
        }
      }
    }
  }
}
