//
//  VerifyEmailView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct VerifyEmailView: View {
    let email: String
    let engine: Engine
    let onBackToLogin: () -> Void
    let onResendEmail: () async -> Void
    let onVerificationSuccess: (() -> Void)? // Callback quand la vérification réussit
    let onSkipVerification: (() -> Void)? // Optionnel : pour continuer sans vérification

    @State private var verificationCode = ""
    @State private var secondsLeft = 60
    @State private var isResending = false
    @State private var isVerifying = false
    @State private var showResendSuccess = false
    @State private var showResendError = false
    @State private var showVerificationError = false
    @State private var verificationErrorMessage = ""

    var body: some View {
        ZStack {
            // MARK: - Fullscreen Background Image
            GeometryReader { geometry in
                Image("launchImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(
                        // Dark overlay
                        Color.black.opacity(0.65)
                    )
            }
            .ignoresSafeArea()
            
            // MARK: - Content
            VStack(spacing: 0) {
                // MARK: - Back Button (Top Left)
                HStack {
                    Button(action: onBackToLogin) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Retour")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                        )
                    }
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: - Main Content (Centered)
                VStack(spacing: 32) {
                    // Icon - Shield
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.brown.opacity(0.8))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "shield.fill")
                                .font(.system(size: 50, weight: .regular))
                                .foregroundColor(.white)
                        )
                    
                    // Title
                    Text("Vérification")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Instructions
                    VStack(spacing: 8) {
                        Text("Entrez le code à 6 chiffres envoyé à")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(email.isEmpty ? "Email non disponible" : email)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .onAppear {
                                print("🔍 [VERIFY] Email in view: '\(email)'")
                            }
                    }
                    
                    // Code Input Field
                    CodeInputField(code: $verificationCode, numberOfDigits: 6) {
                        // Code complet, vérifier automatiquement
                        verifyCode()
                    }
                    .padding(.horizontal, 20)
                    
                    // Message d'erreur
                    if !verificationErrorMessage.isEmpty {
                        Text(verificationErrorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Bouton Vérifier
                    Button {
                        verifyCode()
                    } label: {
                        ZStack {
                            if isVerifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Vérifier")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(verificationCode.count != 6 || isVerifying)
                    .opacity(verificationCode.count == 6 ? 1.0 : 0.6)
                    .padding(.horizontal, 20)
                    
                    // Resend Code Link
                    Button {
                        Task {
                            guard secondsLeft == 0, !isResending else { return }
                            isResending = true
                            do {
                                await onResendEmail()
                                showResendSuccess = true
                                resetTimer()
                            } catch {
                                showResendError = true
                            }
                            isResending = false
                        }
                    } label: {
                        if isResending {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            let resendTitle: String = {
                                if secondsLeft > 0 {
                                    return "Renvoyer le code (\(secondsLeft)s)"
                                } else {
                                    return "Renvoyer le code"
                                }
                            }()
                            
                            Text(resendTitle)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .disabled(secondsLeft > 0 || isResending)
                    .opacity(secondsLeft > 0 || isResending ? 0.5 : 1.0)
                    
                    // Spam folder instruction
                    Text("Vérifiez votre dossier spam si vous ne voyez pas l'email")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .padding(.vertical, 40)
                
                Spacer()
            }
        }
        .onAppear { 
            startTimer()
            print("🔍 [VERIFY] VerifyEmailView appeared with email: '\(email)'")
            if email.isEmpty {
                print("❌ [VERIFY] WARNING: Email is empty!")
            }
        }
        .alert("Email renvoyé", isPresented: $showResendSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Un nouvel email de vérification a été envoyé.")
        }
        .alert("Erreur", isPresented: $showResendError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Impossible de renvoyer l'email. Veuillez réessayer plus tard.")
        }
        .alert("Erreur de vérification", isPresented: $showVerificationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(verificationErrorMessage.isEmpty ? "Code invalide ou expiré. Veuillez réessayer." : verificationErrorMessage)
        }
    }
    
    private func verifyCode() {
        guard verificationCode.count == 6, !isVerifying else { return }
        
        // Vérifier que l'email n'est pas vide
        guard !email.isEmpty else {
            print("❌ [VERIFY] Email is empty!")
            verificationErrorMessage = "Email manquant. Veuillez réessayer."
            showVerificationError = true
            return
        }
        
        isVerifying = true
        verificationErrorMessage = ""
        
        let emailToVerify = email.trimmingCharacters(in: .whitespaces).lowercased()
        let codeToVerify = verificationCode.trimmingCharacters(in: .whitespaces)
        
        print("🔍 [VERIFY] Verifying code for email: '\(emailToVerify)', code: '\(codeToVerify)'")
        
        Task {
            let response = await engine.userService.verifyEmail(email: emailToVerify, code: codeToVerify)
            
            await MainActor.run {
                isVerifying = false
                
                switch response {
                case .success:
                    // Vérification réussie
                    onVerificationSuccess?()
                case .failure(let error):
                    verificationErrorMessage = error.localizedDescription
                    showVerificationError = true
                    // Réinitialiser le code pour permettre une nouvelle tentative
                    verificationCode = ""
                }
            }
        }
    }

    private func startTimer() {
        Task {
            while secondsLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                if secondsLeft > 0 {
                    secondsLeft -= 1
                }
            }
        }
    }

    private func resetTimer() {
        secondsLeft = 60
        startTimer()
    }
}
