//
//  BelDetailingApp.swift
//  BelDetailing
//
//  Created by Achraf Benali on 04/11/2025.
//
import SwiftUI

@main
struct BelDetailingApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false

    let engine = Engine(mock: true)

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    // Étape 1️⃣ : Onboarding
                    OnboardingView()
                } else if !hasSeenWelcome {
                    // Étape 2️⃣ : Welcome
                    WelcomeView(
                        onStart: {
                            hasSeenWelcome = true
                        },
                        onLogin: {
                            hasSeenWelcome = true
                            // ici tu pourras ouvrir ta future AuthView
                        }
                    )
                } else {
                    // Étape 3️⃣ : Application principale
                    MainTabView(engine: engine)
                }
            }
        }
    }
}
