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
        // Vérifier l'état de l'autorisation Apple avant de faire la requête
        let provider = ASAuthorizationAppleIDProvider()
        
        // Vérifier si l'utilisateur a déjà un compte Apple connecté
        provider.getCredentialState(forUserID: getStoredAppleUserID()) { [weak self] state, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch state {
                case .authorized:
                    // L'utilisateur est déjà autorisé, on peut procéder
                    self.performAppleSignIn()
                case .revoked, .notFound:
                    // L'utilisateur a révoqué ou n'a pas de compte, on fait une nouvelle requête
                    self.performAppleSignIn()
                case .transferred:
                    // Compte transféré (rare), on fait une nouvelle requête
                    self.performAppleSignIn()
                @unknown default:
                    // Cas inconnu, on essaie quand même
                    self.performAppleSignIn()
                }
            }
        }
    }
    
    private func performAppleSignIn() {
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
    
    private func getStoredAppleUserID() -> String {
        // Récupérer l'ID Apple stocké (si disponible)
        return UserDefaults.standard.string(forKey: "apple_user_id") ?? ""
    }
    
    private func storeAppleUserID(_ userID: String) {
        // Stocker l'ID Apple pour les vérifications futures
        UserDefaults.standard.set(userID, forKey: "apple_user_id")
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

        // Stocker l'ID Apple pour les vérifications futures
        let appleUserID = credential.user
        storeAppleUserID(appleUserID)

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

        // ⚠️ GESTION EMAIL MASQUÉ
        // Si email est nil (masqué), on utilise l'ID Apple comme identifiant
        // Le backend devra gérer ce cas
        var email = credential.email
        
        // Si email est masqué et qu'on a déjà un compte, on peut récupérer l'email depuis le backend
        if email == nil {
            // Essayer de récupérer l'email depuis le profil utilisateur existant
            // Si l'utilisateur a déjà un compte, le backend devrait le reconnaître via l'ID Apple
            print("⚠️ [Apple Sign In] Email masqué, utilisation de l'ID Apple comme identifiant")
        }

        // Retry logic avec maximum 2 tentatives
        var attempts = 0
        let maxAttempts = 2
        
        while attempts < maxAttempts {
            let response = await userService.loginWithApple(
                identityToken: identityToken,
                authorizationCode: authCodeString,
                fullName: fullNameString,
                email: email
            )

            switch response {
            case .success(let session):
                self.isLoading = false
                self.errorMessage = nil
                
                // ✅ ASSOCIER USER ID AVEC ONESIGNAL
                let userId = session.user.id
                NotificationsManager.shared.loginOneSignal(userId: userId)
                
                // Analytics: User logged in
                FirebaseManager.shared.logEvent(
                    FirebaseManager.Event.userLoggedIn,
                    parameters: ["method": "apple"]
                )
                
                self.onLoginSuccess()
                return // ✅ Succès, on sort
                
            case .failure(let error):
                attempts += 1
                
                // Si c'est une erreur réseau et qu'on n'a pas atteint le max, on réessaie
                if attempts < maxAttempts && isNetworkError(error) {
                    print("⚠️ [Apple Sign In] Erreur réseau, nouvelle tentative (\(attempts)/\(maxAttempts))")
                    // Attendre 1 seconde avant de réessayer
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    continue
                } else {
                    // Erreur finale ou erreur non-réseau
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
            }
        }
    }
    
    // MARK: - Helper: Détecter erreurs réseau
    
    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        // Erreurs réseau courantes
        return nsError.domain == NSURLErrorDomain && (
            nsError.code == NSURLErrorNotConnectedToInternet ||
            nsError.code == NSURLErrorTimedOut ||
            nsError.code == NSURLErrorNetworkConnectionLost ||
            nsError.code == NSURLErrorCannotConnectToHost
        )
    }

    private func handleGoogleToken(idToken: String) async {
          let response = await userService.loginWithGoogle(idToken: idToken)

          switch response {
          case .success(let session):
              self.isLoading = false
              self.errorMessage = nil
              
              // ✅ ASSOCIER USER ID AVEC ONESIGNAL
              let userId = session.user.id
              NotificationsManager.shared.loginOneSignal(userId: userId)
              
              // Analytics: User logged in
              FirebaseManager.shared.logEvent(
                  FirebaseManager.Event.userLoggedIn,
                  parameters: ["method": "google"]
              )
              
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
