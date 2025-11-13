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
                        onLogin: { path.append("login") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "login":
                    LoginView(
                        onBack: { path.removeLast() },
                        onApple: { print("Apple login") },
                        onGoogle: { print("Google login") },
                        onEmail: { path.append("loginEmail") },
                        onShowTerms: { print("Show terms") },
                        onShowPrivacy: { print("Show privacy") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "loginEmail":
                    EmailLoginView(
                        onBack: { path.removeLast() },
                        onCreateAccount: { path.append("signupRole") }
                    )
                    .navigationBarBackButtonHidden(true)

                case "signupRole":
                    SignupRoleSelectionView(engine: engine) { selectedRole in
                        path.append(selectedRole.rawValue)
                    }

                case UserRole.customer.rawValue:
                    SignupFormView(
                        role: .customer,
                        onBack: { path.removeLast() },
                        onSubmit: {
                            // ✅ Quand l’inscription est terminée :
                            path.append("mainTabs")
                        }
                    )

                case UserRole.company.rawValue:
                    SignupFormView(
                        role: .company,
                        onBack: { path.removeLast() },
                        onSubmit: { path.append("mainTabs") }
                    )

                case UserRole.provider.rawValue:
                    SignupFormView(
                        role: .provider,
                        onBack: { path.removeLast() },
                        onSubmit: { path.append("mainTabs") }
                    )

                // ✅ La route finale : ton app avec les tabs
                case "mainTabs":
                    MainTabView(engine: engine)
                        .navigationBarBackButtonHidden(true)

                default:
                    EmptyView()
                }
            }
        }
    }
}
