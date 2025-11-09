//
//  BelDetailingApp.swift
//  BelDetailing
//
//  Created by Achraf Benali on 04/11/2025.
//// BelDetailingApp.swift
import SwiftUI
@main
struct BelDetailingApp: App {
  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
  @AppStorage("forceWelcome") private var forceWelcome = true  // toujours à true pour tests
  let engine = Engine(mock: true)

  var body: some Scene {
    WindowGroup {
      WelcomeView(
        onStart: {
          hasSeenOnboarding = false   // ✅ toujours relancer l’onboarding
          forceWelcome = false         // ✅ toujours afficher le Welcome
        },
        onLogin: {
          // pas encore actif
        }
      )
    }
  }
}
