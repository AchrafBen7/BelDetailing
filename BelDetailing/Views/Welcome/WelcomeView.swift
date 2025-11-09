//
//  WelcomeView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 09/11/2025.
//

import SwiftUI
import RswiftResources

struct WelcomeView: View {
  var onStart: () -> Void = {}
  var onLogin: () -> Void = {}
  
  @State private var contentVisible = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 0) {
        // MARK: - Fullscreen Header Image
        GeometryReader { geometry in
          Image("launchImage")
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width,
                   height: max(geometry.size.height, 420)) // plus haut = immersion
            .clipped()
            .overlay(
              LinearGradient(
                gradient: Gradient(colors: [.clear, .white]),
                startPoint: .center,
                endPoint: .bottom
              )
              .frame(height: 220)
              .padding(.top, 200),
              alignment: .bottom
            )
            .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
        }
        .frame(height: 420)
        .ignoresSafeArea(edges: .top)

        // MARK: - Main Content
        VStack(spacing: 28) {
          // Titre principal
          VStack(spacing: 8) {
            R.string.localizable.welcomeTitle()
              .textView(style: .title, multilineAlignment: .center)
            R.string.localizable.welcomeSubtitle()
              .textView(style: .description, multilineAlignment: .center)
          }
          .padding(.horizontal, 28)
          .padding(.top, -20)

          // MARK: - Avantages (3 cartes)
          VStack(spacing: 16) {
            WelcomeFeatureRow(
              icon: "sparkles",
              title: R.string.localizable.welcomeProsTitle(),
              subtitle: R.string.localizable.welcomeProsSubtitle()
            )
            WelcomeFeatureRow(
              icon: "shield",
              title: R.string.localizable.welcomeSecureTitle(),
              subtitle: R.string.localizable.welcomeSecureSubtitle()
            )
            WelcomeFeatureRow(
              icon: "clock",
              title: R.string.localizable.welcomeFastTitle(),
              subtitle: R.string.localizable.welcomeFastSubtitle()
            )
          }
          .padding(.horizontal, 24)

          // MARK: - Statistiques
          HStack(spacing: 32) {
            WelcomeStat(
              title: R.string.localizable.welcomeStatsProfessionals(),
              value: "500+"
            )
            WelcomeStat(
              title: R.string.localizable.welcomeStatsRating(),
              value: "4.9",
              systemIcon: "star.fill",
              iconColor: Color(R.color.secondaryOrange)
            )
            WelcomeStat(
              title: R.string.localizable.welcomeStatsBookings(),
              value: "10k+"
            )
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(.ultraThinMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 22))
          .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
          .padding(.horizontal, 24)
            // MARK: - Boutons
            VStack(spacing: 14) {
              Button(action: onStart) {
                R.string.localizable.commonStart()
                  .textView(style: .buttonCTA, multilineAlignment: .center)
              }
              .buttonStyle(WelcomePrimaryButton())

                Button(action: onLogin) {
                  R.string.localizable.authLogin()
                    .textView(style: .buttonSecondary, multilineAlignment: .center)
                }
                .buttonStyle(WelcomeSecondaryButton())
            }

          .padding(.horizontal, 28)
          .padding(.bottom, 60)
        }
        .opacity(contentVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.9), value: contentVisible)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .onAppear { contentVisible = true }
  }
}

// MARK: - Feature Card
struct WelcomeFeatureRow: View {
  let icon: String
  let title: String
  let subtitle: String

  var body: some View {
    HStack(spacing: 14) {
      Image(systemName: icon)
        .font(.system(size: 22))
        .foregroundColor(.black)
        .frame(width: 46, height: 46)
        .background(Color.gray.opacity(0.1))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.system(size: 17, weight: .semibold))
        Text(subtitle)
          .font(.system(size: 15))
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding(.vertical, 14)
    .padding(.horizontal, 16)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
  }
}

// MARK: - Stats
struct WelcomeStat: View {
  let title: String
  let value: String
  var systemIcon: String? = nil
  var iconColor: Color = Color(R.color.secondaryOrange)

  var body: some View {
    VStack(spacing: 6) {
      HStack(spacing: 5) {
        if let systemIcon {
          Image(systemName: systemIcon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(iconColor)
        }
        Text(value)
          .font(.system(size: 21, weight: .bold))
      }
      Text(title)
        .font(.system(size: 14))
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  WelcomeView()
}
