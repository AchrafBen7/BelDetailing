//
//  AppStyle.swift
//  BelDetailing
//
//  Created by Achraf Benali on 05/11/2025.
//

import Foundation
import SwiftUI
import RswiftResources

struct AppStyle {
    enum Padding: CGFloat {
       case verySmall8 = 8
       case small16 = 16
       case medium24 = 24
       case big32 = 32
     }
    enum TextStyle {
        case title
        case heroTitle
        case sectionTitle
        case buttonSecondary
        case buttonCTA
        case chipLabel
        case description
        case navigationAction
        case navigationTitle
        var size: CGFloat {
            switch self {
            case.title: return 37
            case.heroTitle: return 52
            case.sectionTitle: return 22
            case.buttonCTA: return 18
            case.chipLabel: return 15
            case.buttonSecondary: return 18
            case.description: return 20
            case.navigationAction: return 18
            case.navigationTitle: return 28
            }
        }
        var font: Font {
            switch self {
            case.title,.heroTitle, .sectionTitle, .buttonCTA,.buttonSecondary, .navigationAction, .navigationTitle: return Font.custom(R.font.avenirNextLTProBold, size: size)
            case.description, .chipLabel: return Font.custom(R.font.avenirNextLTProRegular, size: size)
            }
        }
        var defaultColor: Color {
            switch self {
            case.title, .sectionTitle,.navigationTitle,.chipLabel, .heroTitle: return Color(R.color.primaryText)
            case.buttonCTA: return Color.white
            case .buttonSecondary:return Color(R.color.primaryText)
            case.description: return Color(R.color.secondaryText)
            case.navigationAction: return Color(R.color.primaryBlue)}
        }
    }
}

struct FilterChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(AppStyle.TextStyle.chipLabel.font)                 // ⬅️ cohérent avec AppStyle
        .foregroundColor(isSelected ? .white : Color(R.color.primaryText))
        .padding(.vertical, AppStyle.Padding.verySmall8.rawValue + 2)
        .padding(.horizontal, AppStyle.Padding.small16.rawValue + 6)
        .background(
          Group {
            if isSelected {
              Capsule()
                .fill(Color.black)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
            } else {
              Capsule()
                .fill(Color.white)
                .overlay(
                  Capsule().stroke(Color.gray.opacity(0.35), lineWidth: 1.2)
                )
            }
          }
        )
    }
    .buttonStyle(HighlightButton())
  }
}
