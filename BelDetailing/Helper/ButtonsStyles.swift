//
//  ButtonsStyles.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI

// MARK: - Effet d'appui léger
struct HighlightButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay(Color.black.opacity(configuration.isPressed ? 0.2 : 0))
  }
}

// MARK: - Bouton principal global
struct PrimaryButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppStyle.TextStyle.buttonCTA.font)
      .padding()
      .foregroundStyle(.white)
      .background(Color.accentColor)
      .clipShape(Capsule())
      .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}

// MARK: - Bouton secondaire global
struct SecondaryButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppStyle.TextStyle.buttonCTA.font)
      .padding()
      .foregroundStyle(Color.accentColor)
      .background(configuration.isPressed ? Color(uiColor: .lightGray).opacity(0.2) : .white)
      .opacity(configuration.isPressed ? 0.8 : 1.0)
      .overlay(
        Capsule()
          .stroke(Color.accentColor, lineWidth: 1.0)
      )
      .clipShape(Capsule())
  }
}

// MARK: - Welcome View : Boutons dédiés
struct WelcomePrimaryButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppStyle.TextStyle.buttonCTA.font)
      .frame(maxWidth: .infinity)
      .frame(height: 56) // ajustement pour ratio parfait
      .foregroundColor(.white)
      .background(Color.black.opacity(configuration.isPressed ? 0.85 : 1))
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
  }
}

struct WelcomeSecondaryButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppStyle.TextStyle.buttonCTA.font)
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(
        (configuration.isPressed ? Color.gray.opacity(0.08) : Color.white)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(Color.gray.opacity(0.5), lineWidth: 1.2)
      )
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
      .foregroundStyle(.black) // ✅ la couleur du texte forcée ici
  }
}
