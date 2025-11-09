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
        // MARK: - Image de couverture
        ZStack(alignment: .bottom) {
          Image("launchImage")
            .resizable()
            .scaledToFill()
            .frame(height: 280)
            .clipped()
          
          // Dégradé blanc pour fondre vers la section suivante
          LinearGradient(
            gradient: Gradient(colors: [.clear, .white]),
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: 140)
        }

        // MARK: - Contenu principal
        VStack(spacing: 24) {
          // Titre principal
          VStack(spacing: 6) {
            R.string.localizable.welcomeTitle()
              .textView(style: .title, multilineAlignment: .center)
            R.string.localizable.welcomeSubtitle()
              .textView(style: .description, multilineAlignment: .center)
          }
          .padding(.horizontal, 24)
          .padding(.top, 8)

          // MARK: - Avantages
          VStack(spacing: 16) {
            WelcomeFeatureRow(
              icon: "sparkles",
              title: R.string.localizable.welcomeTitle(),
              subtitle: R.string.localizable.welcomeSubtitle()
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
            // MARK: - Statistiques
            HStack(spacing: 24) {
              WelcomeStat(title: R.string.localizable.welcomeStatsProfessionals(), value: "500+")
              WelcomeStat(title: R.string.localizable.welcomeStatsRating(),
                          value: "4.9",
                          systemIcon: "star.fill",
                          iconColor: Color(R.color.secondaryOrange))
              WelcomeStat(title: R.string.localizable.welcomeStatsBookings(), value: "10k+")
            }
            .padding(.top, 8)

          // MARK: - Boutons
          VStack(spacing: 12) {
            Button(action: onStart) {
              R.string.localizable.commonStart()
                .textView(style: .buttonCTA, multilineAlignment: .center)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButton())

            Button(action: onLogin) {
              R.string.localizable.authLogin()
                .textView(style: .buttonCTA, overrideColor: .black, multilineAlignment: .center)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButton())
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 32)
        }
        .background(
          RoundedRectangle(cornerRadius: 24)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -4)
        )
        .offset(y: -20)
        .opacity(contentVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.9), value: contentVisible)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .onAppear { contentVisible = true }
  }
}

// MARK: - Sous-composants
struct WelcomeFeatureRow: View {
  let icon: String
  let title: String
  let subtitle: String

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 22))
        .foregroundColor(.black)
        .frame(width: 40, height: 40)
        .background(Color.gray.opacity(0.1))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 16, weight: .semibold))
        Text(subtitle)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding()
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
  }
}

struct WelcomeStat: View {
  let title: String
  let value: String
  var systemIcon: String? = nil
  var iconColor: Color = Color(R.color.secondaryOrange)

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 6) {
        if let systemIcon {
          Image(systemName: systemIcon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(iconColor)
        }
        Text(value)
          .font(.system(size: 20, weight: .bold))
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
