import SwiftUI
import SwiftUI

struct RootView: View {
    @State var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @StateObject var tabBarVisibility = TabBarVisibility()
    @StateObject var mainTabSelection = MainTabSelection()

    let engine: Engine

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            } else if isLoggedIn {
                MainTabView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .environmentObject(mainTabSelection)
            } else {
                AuthFlowView(
                    engine: engine,
                    isLoggedIn: $isLoggedIn
                )
            }
        }
        .onAppear {
            if let token = StorageManager.shared.getAccessToken(),
               !token.isEmpty {
                isLoggedIn = true
            }
        }
    }
}
