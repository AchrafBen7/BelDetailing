//
//  EmailLoginView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//

import SwiftUI
import RswiftResources

struct EmailLoginView: View {
  var onBack: () -> Void = {}
  var onCreateAccount: () -> Void = {}

  @State private var email: String = ""
  @State private var password: String = ""
  @FocusState private var focusedField: Field?

  enum Field { case email, password }

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {

        // MARK: - Flèche + texte “Retour” en haut à gauche
          Button(action: onBack) {
            HStack(spacing: 4) {
              Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
              Text(R.string.localizable.commonBack())   // ← localizable
                .font(.system(size: 17))
            }
            .foregroundColor(.gray)
          }
          .padding(.top, 8)

        // MARK: - Header
        VStack(alignment: .leading, spacing: 6) {
          Text(R.string.localizable.emailLoginTitle() + ".") // "email login."
            .font(Font.custom(R.font.avenirNextLTProBold, size: 42))
            .foregroundColor(Color(R.color.primaryText))

          Text(R.string.localizable.emailLoginSubtitle()) // "Connectez-vous à votre compte"
            .font(Font.custom(R.font.avenirNextLTProRegular, size: 18))
            .foregroundColor(Color(R.color.secondaryText))
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .leading)

        // MARK: - Email Field
        VStack(alignment: .leading, spacing: 6) {
          Text(R.string.localizable.emailLoginEmailLabel())
            .font(.system(size: 15, weight: .semibold))
          HStack {
            Image(systemName: "envelope")
              .foregroundColor(.gray)
            TextField(R.string.localizable.emailLoginEmailPlaceholder(), text: $email)
              .textContentType(.emailAddress)
              .keyboardType(.emailAddress)
              .focused($focusedField, equals: .email)
              .autocapitalization(.none)
          }
          .padding()
          .background(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2)))
        }

        // MARK: - Password Field
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text(R.string.localizable.emailLoginPasswordLabel())
              .font(.system(size: 15, weight: .semibold))
            Spacer()
            Button(action: { print("Mot de passe oublié ?") }) {
              Text(R.string.localizable.emailLoginForgot())
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
          }

          HStack {
            Image(systemName: "lock")
              .foregroundColor(.gray)
            SecureField("•••••••", text: $password)
              .focused($focusedField, equals: .password)
          }
          .padding()
          .background(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2)))
        }

        // MARK: - Main Button
        Button(action: { print("Connexion avec email") }) {
          R.string.localizable.emailLoginCTA()
            .textView(style: .buttonCTA)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 3)
        }
        .padding(.top, 8)

        // MARK: - Signup link
        HStack(spacing: 4) {
          Text(R.string.localizable.emailLoginNoAccount())
            .foregroundColor(.gray)
          Button(action: onCreateAccount) {
            Text(R.string.localizable.emailLoginCreateAccount())
              .fontWeight(.semibold)
              .foregroundColor(.black)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)

        // MARK: - Divider
        HStack {
          Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
          Text("OU")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray)
          Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
        }
        .padding(.vertical, 8)

        // MARK: - Social buttons
        VStack(spacing: 14) {
          Button(action: { print("Google login") }) {
            HStack {
              Image(systemName: "g.circle.fill")
              Text(R.string.localizable.emailLoginGoogle())
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.4)))
          }

          Button(action: { print("Apple login") }) {
            HStack {
              Image(systemName: "applelogo")
              Text(R.string.localizable.emailLoginApple())
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.4)))
          }
        }
        .padding(.top, 4)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 60)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true) // ✅ empêche le header centré
  }
}
