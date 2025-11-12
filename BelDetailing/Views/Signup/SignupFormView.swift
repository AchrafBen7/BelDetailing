//
//  SignupFormView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//

import SwiftUI
import RswiftResources

struct SignupFormView: View {
  let role: UserRole
  var onBack: () -> Void = {}
  var onSubmit: () -> Void = {}
  var onLogin: () -> Void = {}

  @State private var fullName = ""
  @State private var email = ""
  @State private var phone = ""
  @State private var vatNumber = ""
  @State private var password = ""

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {

        // === HEADER ===
        Button(action: onBack) {
          HStack(spacing: 6) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .semibold))
            Text(R.string.localizable.commonBack())
              .font(.system(size: 17))
          }
          .foregroundColor(.gray)
          .frame(height: 44, alignment: .leading)
          .contentShape(Rectangle())
        }
        .padding(.top, 8)

        Text(R.string.localizable.signupCreateAccountTitle())
          .font(.system(size: 44, weight: .heavy))
          .foregroundColor(.black)
          .multilineTextAlignment(.leading)

        Text(R.string.localizable.signupCreateAccountSubtitle())
          .font(.system(size: 17))
          .foregroundColor(.gray)

        // === BOUTON APPLE ===
        if role == .customer {
          Button(action: {}) {
            Label {
              Text(R.string.localizable.signupContinueApple())
                .font(.system(size: 17, weight: .semibold))
                .baselineOffset(-0.5)
            } icon: {
              Image(systemName: "applelogo")
                .font(.system(size: 18, weight: .regular))
            }
            .labelStyle(.titleAndIcon)
          }
          .buttonStyle(AppleHoverButtonStrongerBorder(fontSize: 17)) // 👈 version améliorée

          // Séparateur centré (sur une seule ligne)
          HStack(spacing: 12) {
            Rectangle()
              .fill(Color.gray.opacity(0.25))
              .frame(height: 1)
            Text(R.string.localizable.signupOrEmail().uppercased())
              .font(.system(size: 13, weight: .medium))
              .foregroundColor(.gray)
              .lineLimit(1)
              .fixedSize() // 👈 empêche de passer sur 2 lignes
            Rectangle()
              .fill(Color.gray.opacity(0.25))
              .frame(height: 1)
          }
          .frame(maxWidth: .infinity)
          .padding(.top, 8)
        }

        // === SECTION TITLE ===
        VStack(alignment: .leading, spacing: 6) {
          Text(R.string.localizable.signupPersonalInfoTitle())
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.black)
          Text(R.string.localizable.signupPersonalInfoSubtitle())
            .font(.system(size: 16))
            .foregroundColor(.gray)
        }

        // === CHAMPS ===
        VStack(spacing: 18) {
          CustomInputField(
            icon: "person",
            title: R.string.localizable.signupFullNameLabel(),
            placeholder: R.string.localizable.signupFullNamePlaceholder(),
            text: $fullName
          )
          CustomInputField(
            icon: "envelope",
            title: R.string.localizable.signupEmailLabel(),
            placeholder: R.string.localizable.signupEmailPlaceholder(),
            text: $email,
            keyboardType: .emailAddress
          )
          CustomInputField(
            icon: "phone",
            title: R.string.localizable.signupPhoneLabel(),
            placeholder: R.string.localizable.signupPhonePlaceholder(),
            text: $phone,
            keyboardType: .phonePad
          )

          if role == .company || role == .provider {
            CustomInputField(
              icon: "doc.text",
              title: R.string.localizable.signupVatLabel(),
              placeholder: R.string.localizable.signupVatPlaceholder(),
              text: $vatNumber
            )
          }

          CustomInputField(
            icon: "lock",
            title: R.string.localizable.signupPasswordLabel(),
            placeholder: R.string.localizable.signupPasswordPlaceholder(),
            text: $password,
            isSecure: true
          )
        }

        // === CTA ===
        Button(action: onSubmit) {
          R.string.localizable.signupCreateAccount()
            .textView(style: .buttonCTA)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)

        // === ALREADY HAVE ACCOUNT ===
        HStack(spacing: 6) {
          Text(R.string.localizable.signupAlreadyAccount())
            .font(.system(size: 16))
            .foregroundColor(.gray)
          Button(action: onLogin) {
            Text(R.string.localizable.signupLoginAction())
              .font(.system(size: 16, weight: .semibold))
              .underline()
              .foregroundColor(.black)
          }
        }
        .padding(.bottom, 40)
      }
      .padding(.horizontal, 24)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
  }
}
