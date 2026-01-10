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
    ZStack {
      // MARK: - Fullscreen Background Image
      GeometryReader { geometry in
        Image("launchImage")
          .resizable()
          .scaledToFill()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .clipped()
          .overlay(
            // Dark overlay
            Color.black.opacity(0.65)
          )
      }
      .ignoresSafeArea()
      
      // MARK: - Content
      VStack(spacing: 0) {
        // Top badge
        HStack {
          brandBadge
          Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        
        Spacer()
        
        // Main content
        VStack(spacing: 0) {
          // Title & Subtitle (aligned left)
          VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.welcomeTitleNew())
              .font(.system(size: 34, weight: .bold))
              .foregroundColor(.white)
              .multilineTextAlignment(.leading)
              .lineSpacing(4)
            
            Text(R.string.localizable.welcomeSubtitleNew())
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.95))
              .multilineTextAlignment(.leading)
              .lineSpacing(2)
          }
          .padding(.horizontal, 28)
          .padding(.bottom, 32)
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // Features Box
          featuresBox
            .padding(.horizontal, 20)
            .padding(.bottom, 40) // Plus d'espace avant les boutons
          
          // Buttons
          VStack(spacing: 14) {
            Button(action: onStart) {
              HStack(spacing: 12) {
                Text(R.string.localizable.commonStart())
                  .font(.system(size: 18, weight: .bold))
                  .foregroundColor(.black)
                Image(systemName: "arrow.right")
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(.black)
              }
              .frame(height: 58)
              .frame(maxWidth: .infinity)
              .background(Color.white)
              .clipShape(RoundedRectangle(cornerRadius: 18))
              .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
            .buttonStyle(WelcomeButtonStyle())
            
            Button(action: onLogin) {
              Text(R.string.localizable.authLogin())
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.gray.opacity(0.4))
                .overlay(
                  RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            .buttonStyle(WelcomeButtonStyle())
          }
          .padding(.horizontal, 20)
          
          // Bottom stat
          Text(R.string.localizable.welcomeBottomStat())
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.white.opacity(0.85))
            .padding(.top, 24)
        }
        .padding(.bottom, 50)
      }
      .opacity(contentVisible ? 1 : 0)
      .animation(.easeOut(duration: 0.9), value: contentVisible)
    }
    .onAppear { contentVisible = true }
  }
  
  // MARK: - Brand Badge
  private var brandBadge: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(Color.orange)
        .frame(width: 8, height: 8)
      
      Text("NIOS")
        .font(.system(size: 13, weight: .bold))
        .foregroundColor(.white)
      
      Text("beldetailing")
        .font(.system(size: 13, weight: .regular))
        .foregroundColor(.white.opacity(0.85))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 9)
    .background(Color.gray.opacity(0.4))
    .clipShape(RoundedRectangle(cornerRadius: 22))
  }
  
  // MARK: - Features Box
  private var featuresBox: some View {
    VStack(alignment: .leading, spacing: 18) {
      WelcomeFeatureItem(
        text: R.string.localizable.welcomeFeatureQuality()
      )
      WelcomeFeatureItem(
        text: R.string.localizable.welcomeFeatureFast()
      )
      WelcomeFeatureItem(
        text: R.string.localizable.welcomeFeatureTrust()
      )
    }
    .padding(.vertical, 22)
    .padding(.horizontal, 20)
    .background(Color.gray.opacity(0.3))
    .clipShape(RoundedRectangle(cornerRadius: 22))
  }
}

// MARK: - Feature Item
struct WelcomeFeatureItem: View {
  let text: String
  
  var body: some View {
    HStack(spacing: 14) {
      // Checkmark circle
      ZStack {
        Circle()
          .fill(Color.white.opacity(0.25))
          .frame(width: 26, height: 26)
        
        Image(systemName: "checkmark")
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(.white)
      }
      
      Text(text)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.white)
        .lineSpacing(2)
      
      
      Spacer()
    }
  }
}

// MARK: - Welcome Button Style
struct WelcomeButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(configuration.isPressed ? 0.9 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

#Preview {
  WelcomeView()
}
