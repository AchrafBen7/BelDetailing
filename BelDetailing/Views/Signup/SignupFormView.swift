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

  private let side = CGFloat(24)

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {

        // HEADER — aligné à gauche, une seule flèche
        SignupHeroHeader(onBack: onBack)
          .padding(.top, 8)

        // BOUTON APPLE (particulier uniquement)
        if role == .customer {
            // Dans SignupFormView (label du bouton)
            Button(action: {}) {
              Label {
                Text(R.string.localizable.signupContinueApple())
                  .font(.system(size: 17, weight: .semibold))   // ← était plus grand, on réduit
                  .baselineOffset(-0.5)                          // ← micro correction verticale
              } icon: {
                Image(systemName: "applelogo")
                  .font(.system(size: 18, weight: .regular))     // icône légèrement > texte
              }
              .labelStyle(.titleAndIcon)
            }
            .buttonStyle(AppleHoverButton(fontSize: 17))          // voir style ci-dessous


          SeparatorChip(text: R.string.localizable.signupOrEmail())
        }

        // SECTION TITLE
        VStack(alignment: .leading, spacing: 6) {
          Text(R.string.localizable.signupPersonalInfoTitle())
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.black)
          Text(R.string.localizable.signupPersonalInfoSubtitle())
            .font(.system(size: 16))
            .foregroundColor(.gray)
        }

        // CHAMPS
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

        // CTA
        Button(action: onSubmit) {
          R.string.localizable.signupCreateAccount()
            .textView(style: .buttonCTA)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)

        // ALREADY HAVE ACCOUNT
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
      // ← applique la même marge à tout : titre, bouton, champs, etc.
      .padding(.horizontal, side)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
  }
}
