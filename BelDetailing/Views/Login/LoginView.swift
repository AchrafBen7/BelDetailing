//
//  LoginView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//
//
//  LoginView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Pill Button
struct PillLoginButton: View {
  enum Kind { case filledBlack, outlineLight }

  let kind: Kind
  let icon: String
  let title: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        Image(systemName: icon)
          .font(.system(size: 19, weight: .medium))
        Text(title)
          .font(.system(size: 17, weight: .semibold))
      }
      .frame(maxWidth: .infinity, minHeight: 60)
      .foregroundColor(kind == .filledBlack ? .white : .black)
      .background(kind == .filledBlack ? Color.black : Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 30)
          .stroke(kind == .outlineLight ? Color.gray.opacity(0.4) : .clear, lineWidth: 1)
      )
      .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
      .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Login View
struct LoginView: View {
  var onBack: () -> Void = {}
  var onApple: () -> Void = {}
  var onGoogle: () -> Void = {}
  var onEmail: () -> Void = {}
  var onShowTerms: () -> Void = {}
  var onShowPrivacy: () -> Void = {}

  var body: some View {
    ScrollView(showsIndicators: false) {
      // 👇 Aligne tout le contenu sur la gauche
      VStack(alignment: .leading, spacing: 28) {

        // MARK: - ← Retour (localizable) en haut à gauche
        Button(action: onBack) {
          HStack(spacing: 6) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .semibold))
            Text(R.string.localizable.commonBack())   // "Retour" / "Back" / "Terug"
              .font(.system(size: 17))
          }
          .foregroundColor(.gray)
        }
        // 👇 Force l’ancrage à gauche de la frame
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)

        // MARK: - Header icons
        HStack(spacing: 32) {
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
            .frame(width: 72, height: 72)
            .overlay(
              Image(systemName: "car")
                .font(.system(size: 28))
                .foregroundColor(.gray)
            )

          RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .frame(width: 72, height: 72)
            .overlay(
              Image(systemName: "sparkles")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.black)
            )

          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
            .frame(width: 72, height: 72)
            .overlay(
              Image(systemName: "shield")
                .font(.system(size: 28))
                .foregroundColor(.gray)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)

        // MARK: - Title + subtitle
        VStack(spacing: 8) {
          Text(R.string.localizable.loginTitle())
            .font(.system(size: 30, weight: .heavy))
            .multilineTextAlignment(.center)
            .foregroundColor(.black)

          Text(R.string.localizable.loginSubtitle())
            .font(.system(size: 17))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)

          Text(R.string.localizable.loginDevices())
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)

          // MARK: - Buttons
          VStack(spacing: 16) {
            PillLoginButton(
              kind: .outlineLight,
              icon: "applelogo",
              title: R.string.localizable.loginApple()
            ) { onApple() }

            PillLoginButton(
              kind: .outlineLight,
              icon: "g.circle.fill",
              title: R.string.localizable.loginGoogle()
            ) { onGoogle() }

            // ⬇️ Séparateur "OR sign in with"
            SeparatorChip(text: R.string.localizable.loginOrWithEmail())

            PillLoginButton(
              kind: .filledBlack,
              icon: "envelope",
              title: R.string.localizable.loginEmail()
            ) { onEmail() }
          }
          .padding(.horizontal, 24)
          .padding(.top, 8)

          // MARK: - Footer
          VStack(spacing: 6) {
            Text(R.string.localizable.loginFooterPrefix())
              .font(.system(size: 14))
              .foregroundColor(.gray)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)

            HStack(spacing: 6) {
              Button(action: onShowTerms) {
                Text(R.string.localizable.loginFooterTos())
                  .font(.system(size: 14, weight: .semibold))
                  .underline()
                  .foregroundColor(.black)
              }
              Text(R.string.localizable.loginFooterAnd())
                .font(.system(size: 14))
                .foregroundColor(.gray)
              Button(action: onShowPrivacy) {
                Text(R.string.localizable.loginFooterPrivacy())
                  .font(.system(size: 14, weight: .semibold))
                  .underline()
                  .foregroundColor(.black)
              }
            }
            .frame(maxWidth: .infinity, alignment: .center) // ⬅️ centre la ligne
          }
          .padding(.horizontal, 24)
          .padding(.top, 8)
          .padding(.bottom, 40)

      }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
  }
}
