//
//  ProfileDetailViewComponents.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Composants extraits de ProfileDetailView pour respecter la limite de longueur
//

import SwiftUI
import RswiftResources

// MARK: - Profile Picture Section Component

struct ProfilePictureSection: View {
    let displayName: String
    let companyName: String?
    let role: UserRole
    let logoURL: URL?
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Group {
                if let imageURL = logoURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            ProfilePlaceholder()
                        }
                    }
                } else {
                    ProfilePlaceholder()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 40, y: 40),
                alignment: .bottomTrailing
            )
            
            Text(displayName)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            if let companyName = companyName, !companyName.isEmpty {
                Text(companyName)
                    .font(DesignSystem.Typography.subtitle)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
}

// MARK: - Profile Placeholder Component

struct ProfilePlaceholder: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Colors.border)
            Image(systemName: "person.fill")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

// MARK: - Simple Info Row Component

struct SimpleInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
    }
}

// MARK: - Simple Section Card Component

struct SimpleSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.bottom, DesignSystem.Spacing.xs)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(
            padding: DesignSystem.Spacing.md,
            cornerRadius: DesignSystem.CornerRadius.medium
        )
    }
}

