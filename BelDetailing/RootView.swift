import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    let engine: Engine

    var body: some View {
        if !isLoggedIn {
            // 🌍 Wereld 1: onboarding + welcome + login
            AuthFlowView(
                engine: engine,
                hasSeenOnboarding: $hasSeenOnboarding,
                isLoggedIn: $isLoggedIn
            )
        } else {
            // 🌍 Wereld 2: echte app met tabs (geen onboarding meer in de tree)
            MainTabView(engine: engine)
        }
    }
}
