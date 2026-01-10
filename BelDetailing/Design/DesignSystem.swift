//
//  DesignSystem.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Design System cohérent inspiré Uber-like
//

import SwiftUI
import RswiftResources

// MARK: - Design System Principal

struct DesignSystem {
    
    // MARK: - Colors
    
    struct Colors {
        // Primary Colors
        static let primary = Color.black
        static let primaryText = Color(R.color.primaryText)
        static let secondaryText = Color(R.color.secondaryText)
        
        // Accent Colors
        static let accent = Color(R.color.mainAccent)
        static let accentBlue = Color(R.color.primaryBlue)
        
        // Background Colors
        static let background = Color(R.color.mainBackground)
        static let cardBackground = Color.white
        static let overlayBackground = Color.black.opacity(0.4)
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Border Colors
        static let border = Color.black.opacity(0.1)
        static let borderStrong = Color.black.opacity(0.2)
        
        // Shadow Colors
        static let shadow = Color.black.opacity(0.05)
        static let shadowMedium = Color.black.opacity(0.1)
        static let shadowStrong = Color.black.opacity(0.2)
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Headings
        static let heroTitle = Font.custom(R.font.avenirNextLTProBold, size: 52)
        static let title = Font.custom(R.font.avenirNextLTProBold, size: 37)
        static let sectionTitle = Font.custom(R.font.avenirNextLTProBold, size: 22)
        static let navigationTitle = Font.custom(R.font.avenirNextLTProBold, size: 28)
        
        // Body
        static let body = Font.custom(R.font.avenirNextLTProRegular, size: 16)
        static let bodyBold = Font.custom(R.font.avenirNextLTProBold, size: 16)
        static let description = Font.custom(R.font.avenirNextLTProRegular, size: 20)
        static let subtitle = Font.custom(R.font.avenirNextLTProRegular, size: 18)
        
        // UI Elements
        static let buttonCTA = Font.custom(R.font.avenirNextLTProBold, size: 18)
        static let buttonSecondary = Font.custom(R.font.avenirNextLTProBold, size: 18)
        static let chipLabel = Font.custom(R.font.avenirNextLTProRegular, size: 15)
        static let navigationAction = Font.custom(R.font.avenirNextLTProBold, size: 18)
        
        // Supporting
        static let caption = Font.custom(R.font.avenirNextLTProRegular, size: 14)
        static let infoLabel = Font.custom(R.font.avenirNextLTProRegular, size: 16)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 60
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let pill: CGFloat = 999
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static let small = Shadow(color: Colors.shadow, radius: 2, offsetY: 1)
        static let medium = Shadow(color: Colors.shadowMedium, radius: 4, offsetY: 2)
        static let large = Shadow(color: Colors.shadowStrong, radius: 8, offsetY: 4)
        
        struct Shadow {
            let color: Color
            let radius: CGFloat
            let offsetY: CGFloat
        }
    }
    
    // MARK: - Animation
    
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - Card Style

struct CardStyle: ViewModifier {
    var padding: CGFloat = DesignSystem.Spacing.md
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.medium
    var shadow: DesignSystem.Shadows.Shadow = DesignSystem.Shadows.small
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: shadow.color, radius: shadow.radius, y: shadow.offsetY)
    }
}

extension View {
    func cardStyle(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium,
        shadow: DesignSystem.Shadows.Shadow = DesignSystem.Shadows.small
    ) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius, shadow: shadow))
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonCTA)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.buttonSecondary)
            .foregroundColor(
                isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.5)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isEnabled ? DesignSystem.Colors.borderStrong : DesignSystem.Colors.border,
                        lineWidth: 1.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Text Field Style

struct TextFieldStyle: ViewModifier {
    var isError: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(DesignSystem.Typography.body)
            .foregroundColor(DesignSystem.Colors.primaryText)
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isError ? DesignSystem.Colors.error : DesignSystem.Colors.border,
                        lineWidth: isError ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

extension View {
    func textFieldStyle(isError: Bool = false) -> some View {
        modifier(TextFieldStyle(isError: isError))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    
    init(_ title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Text("Voir tout")
                        .font(DesignSystem.Typography.navigationAction)
                        .foregroundColor(DesignSystem.Colors.accentBlue)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}



