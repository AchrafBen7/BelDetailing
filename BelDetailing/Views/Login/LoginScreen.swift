import SwiftUI

struct LoginScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: LoginViewModel

    @State private var showEmailLogin = false
    private let engine: Engine
    var onSignup: (() -> Void)?

    init(engine: Engine, onLoginSuccess: @escaping () -> Void, onSignup: (() -> Void)? = nil) {
        self.engine = engine
        self.onSignup = onSignup
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(engine: engine, onLoginSuccess: onLoginSuccess)
        )
    }

    var body: some View {
        ZStack {
            LoginView(
                onBack: { dismiss() },
                onApple: { viewModel.signInWithApple() },
                onGoogle: { viewModel.signInWithGoogle() },
                onEmail: { showEmailLogin = true },
                onShowTerms: {},
                onShowPrivacy: {},
                onSignup: {
                    dismiss()
                    onSignup?()
                }
            )

            if viewModel.isLoading {
                Color.black.opacity(0.12).ignoresSafeArea()
                ProgressView().scaleEffect(1.3)
            }
        }
        .sheet(isPresented: $showEmailLogin) {
            NavigationStack {
                EmailLoginView(
                    engine: engine,
                    onBack: { showEmailLogin = false },
                    onCreateAccount: {},
                    onLoginSuccess: {
                        showEmailLogin = false
                        viewModel.onLoginSuccess()
                    }
                )
            }
        }
        .alert("Login error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
