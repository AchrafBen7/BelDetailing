import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @StateObject var tabBarVisibility = TabBarVisibility()
    @StateObject var mainTabSelection = MainTabSelection()   // ⬅️ AJOUT

    let engine: Engine

    var body: some View {
        if !isLoggedIn {
            AuthFlowView(
                engine: engine,
                hasSeenOnboarding: $hasSeenOnboarding,
                isLoggedIn: $isLoggedIn
            )
            .environmentObject(tabBarVisibility)
            .environmentObject(mainTabSelection) // ⬅️ AJOUT
        } else {
            MainTabView(engine: engine)
                .environmentObject(tabBarVisibility)
                .environmentObject(mainTabSelection) // ⬅️ AJOUT
        }
    }
}

