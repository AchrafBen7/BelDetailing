//
//  ButtonsStyles.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import SwiftUI

struct HighlightButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay(Color.black.opacity(configuration.isPressed ? 0.2 : 0))
  }
}
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
