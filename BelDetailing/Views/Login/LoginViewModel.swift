//
//  LoginViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 25/11/2025.
//
import Foundation
import AuthenticationServices
import GoogleSignIn   // via SPM
import UIKit
import Combine

@MainActor
final class LoginViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
      @Published var errorMessage: String?

      private let userService: UserService
      let onLoginSuccess: () -> Void

      init(engine: Engine, onLoginSuccess: @escaping () -> Void) {
          self.userService = engine.userService
          self.onLoginSuccess = onLoginSuccess
      }

    // MARK: - Public API

    func signInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        isLoading = true
        errorMessage = nil
    }

    func signInWithGoogle() {
        guard let rootVC = Self.rootViewController() else {
            errorMessage = "No root view controller"
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.isLoading = false
                    self.errorMessage = "Google token missing"
                    return
                }

                await self.handleGoogleToken(idToken: idToken)
            }
        }
    }

    // MARK: - Private Helpers

    private func handleAppleCredential(_ credential: ASAuthorizationAppleIDCredential) async {
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            self.isLoading = false
            self.errorMessage = "Apple token invalide"
            return
        }

        let authCodeString: String?
        if let authCodeData = credential.authorizationCode {
            authCodeString = String(data: authCodeData, encoding: .utf8)
        } else {
            authCodeString = nil
        }

        let fullNameString: String?
        if let name = credential.fullName {
            let composed = [name.givenName, name.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            fullNameString = composed.isEmpty ? nil : composed
        } else {
            fullNameString = nil
        }

        let email = credential.email // dispo seulement la 1ère fois

        let response = await userService.loginWithApple(
            identityToken: identityToken,
            authorizationCode: authCodeString,
            fullName: fullNameString,
            email: email
        )

        switch response {
        case .success:
            self.isLoading = false
            self.errorMessage = nil
            self.onLoginSuccess()// 👉 ici tu peux envoyer une notification ou callback
        case .failure(let error):
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    private func handleGoogleToken(idToken: String) async {
          let response = await userService.loginWithGoogle(idToken: idToken)

          switch response {
          case .success:
              self.isLoading = false
              self.errorMessage = nil
              self.onLoginSuccess()      // 👈 ICI
          case .failure(let error):
              self.isLoading = false
              self.errorMessage = error.localizedDescription
          }
      }

    private static func rootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewModel: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                await handleAppleCredential(credential)
            } else {
                self.isLoading = false
                self.errorMessage = "Apple credential manquante"
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first ?? UIWindow()
    }
}
