import SwiftUI
import SwiftUI

struct RootView: View {
    @State var isLoggedIn = false
    @State var isCheckingAuth = true
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @StateObject var tabBarVisibility = TabBarVisibility()
    @StateObject var mainTabSelection = MainTabSelection()

    let engine: Engine

    @EnvironmentObject var loadingManager: LoadingOverlayManager

    var body: some View {
        ZStack {
            Group {
                if isCheckingAuth {
                    // Show loading while checking authentication
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                } else if !hasSeenOnboarding {
                    OnboardingView {
                        hasSeenOnboarding = true
                    }
                } else if isLoggedIn {
                    MainTabView(engine: engine)
                        .environmentObject(tabBarVisibility)
                        .environmentObject(mainTabSelection)
                } else {
                    // User not logged in - show WelcomeView immediately
                    AuthFlowView(
                        engine: engine,
                        isLoggedIn: $isLoggedIn
                    )
                }
            }
            .task {
                await checkAuthentication()
            }
            .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
                isLoggedIn = false
            }

            if loadingManager.isLoading {
                LoadingOverlayView()
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Authentication Check
    private func checkAuthentication() async {
        isCheckingAuth = true
        
        // First check if token exists
        guard let token = StorageManager.shared.getAccessToken(),
              !token.isEmpty else {
            // No token - user is not logged in
            isLoggedIn = false
            isCheckingAuth = false
            return
        }
        
        // Verify token is valid by calling API
        let result = await engine.userService.me()
        
        switch result {
        case .success:
            // Token is valid - user is authenticated
            isLoggedIn = true
        case .failure:
            // Token is invalid or expired - clear it and show WelcomeView
            StorageManager.shared.saveAccessToken(nil)
            StorageManager.shared.saveRefreshToken(nil)
            StorageManager.shared.saveUser(nil)
            isLoggedIn = false
        }
        
        isCheckingAuth = false
    }
}
