//
//  EmailLoginView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//

import SwiftUI
import RswiftResources

struct EmailLoginView: View {
  let engine: Engine
  var onBack: () -> Void = {}
  var onCreateAccount: () -> Void = {}
  var onLoginSuccess: () -> Void = {}

  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @FocusState private var focusedField: Field?

  enum Field { case email, password }

  var body: some View {
    ZStack {
      // MARK: - Fullscreen Background Image (heroMain - orange tint)
      GeometryReader { geometry in
        Image(R.image.heroMain.name)
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
        // Top back button
        HStack {
          Button(action: onBack) {
            ZStack {
              Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 40)
              
              Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            }
          }
          Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        
        Spacer()
        
        // MARK: - Translucent Card
        VStack(spacing: 0) {
          // Title & Subtitle
          VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.emailLoginTitle())
              .font(.system(size: 32, weight: .bold))
              .foregroundColor(.white)
              .multilineTextAlignment(.leading)
            
            Text(R.string.localizable.emailLoginSubtitle())
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.9))
              .multilineTextAlignment(.leading)
          }
          .padding(.top, 32)
          .padding(.bottom, 28)
          .padding(.horizontal, 24)
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // MARK: - Form Fields
          VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
              Text(R.string.localizable.emailLoginEmailLabel())
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
              
              HStack(spacing: 12) {
                Image(systemName: "envelope")
                  .font(.system(size: 18))
                  .foregroundColor(.white.opacity(0.7))
                  .frame(width: 24)
                
                TextField(R.string.localizable.emailLoginEmailPlaceholder(), text: $email)
                  .textContentType(.emailAddress)
                  .keyboardType(.emailAddress)
                  .focused($focusedField, equals: .email)
                  .autocapitalization(.none)
                  .foregroundColor(.white)
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 16)
              .background(
                RoundedRectangle(cornerRadius: 14)
                  .fill(Color.white.opacity(0.15))
                  .overlay(
                    RoundedRectangle(cornerRadius: 14)
                      .stroke(Color.white.opacity(0.3), lineWidth: 1)
                  )
              )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text(R.string.localizable.emailLoginPasswordLabel())
                  .font(.system(size: 15, weight: .semibold))
                  .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Button(action: { print("Mot de passe oublié ?") }) {
                  Text(R.string.localizable.emailLoginForgot())
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                }
              }
              
              HStack(spacing: 12) {
                Image(systemName: "lock")
                  .font(.system(size: 18))
                  .foregroundColor(.white.opacity(0.7))
                  .frame(width: 24)
                
                SecureField("•••••••", text: $password)
                  .focused($focusedField, equals: .password)
                  .foregroundColor(.white)
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 16)
              .background(
                RoundedRectangle(cornerRadius: 14)
                  .fill(Color.white.opacity(0.15))
                  .overlay(
                    RoundedRectangle(cornerRadius: 14)
                      .stroke(Color.white.opacity(0.3), lineWidth: 1)
                  )
              )
            }
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 28)
          
          // MARK: - Login Button
          Button {
            if isLoading { return }
            isLoading = true
            
            Task {
              let response = await engine.userService.login(email: email, password: password)
              switch response {
              case .success(let session):
                // ✅ ASSOCIER USER ID AVEC ONESIGNAL
                let userId = session.user.id
                NotificationsManager.shared.loginOneSignal(userId: userId)
                
                await MainActor.run {
                  isLoading = false
                  onLoginSuccess()
                }
              case .failure(let err):
                await MainActor.run {
                  isLoading = false
                  print("❌ Login error: \(err.localizedDescription)")
                }
              }
            }
          } label: {
            ZStack {
              if isLoading {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
              } else {
                Text(R.string.localizable.emailLoginCTA())
                  .font(.system(size: 18, weight: .bold))
                  .foregroundColor(.black)
              }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
          }
          .disabled(email.isEmpty || password.isEmpty || isLoading)
          .opacity((email.isEmpty || password.isEmpty) ? 0.5 : 1.0)
          .padding(.horizontal, 24)
          .padding(.bottom, 24)
          
          // MARK: - Signup Link
          Button(action: onCreateAccount) {
            HStack(spacing: 4) {
              Text(R.string.localizable.emailLoginNoAccount())
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
              Text(R.string.localizable.emailLoginCreateAccount())
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            }
          }
          .padding(.bottom, 32)
        }
        .background(
          ZStack {
            RoundedRectangle(cornerRadius: 24)
              .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 24)
              .fill(Color.black.opacity(0.4))
          }
        )
        .padding(.horizontal, 20)
        
        Spacer()
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}
