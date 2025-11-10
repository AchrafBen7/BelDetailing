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
        case sectionTitle
        case buttonSecondary
        case buttonCTA
        case description
        case navigationAction
        case navigationTitle
        var size: CGFloat {
            switch self {
            case.title: return 37
            case.sectionTitle: return 22
            case.buttonCTA: return 18
            case.buttonSecondary: return 18
            case.description: return 20
            case.navigationAction: return 18
            case.navigationTitle: return 28
            }
        }
        var font: Font {
            switch self {
            case.title, .sectionTitle, .buttonCTA,.buttonSecondary, .navigationAction, .navigationTitle: return Font.custom(R.font.avenirNextLTProBold, size: size)
            case.description: return Font.custom(R.font.avenirNextLTProRegular, size: size)
            }
        }
        var defaultColor: Color {
            switch self {
            case.title, .sectionTitle,.navigationTitle: return Color(R.color.primaryText)
            case.buttonCTA: return Color.white
            case .buttonSecondary:return Color(R.color.primaryText)
            case.description: return Color(R.color.secondaryText)
            case.navigationAction: return Color(R.color.primaryBlue)}
        }
    }
}
