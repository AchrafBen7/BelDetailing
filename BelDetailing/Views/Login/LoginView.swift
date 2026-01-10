//
//  LoginView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Login View
struct LoginView: View {
  var onBack: () -> Void = {}
  var onApple: () -> Void = {}
  var onGoogle: () -> Void = {}
  var onEmail: () -> Void = {}
  var onShowTerms: () -> Void = {}
  var onShowPrivacy: () -> Void = {}
  var onSignup: () -> Void = {}

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
        // Top back button
        HStack {
          Button(action: onBack) {
            ZStack {
              Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 40)
              
              Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            }
          }
          Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        
        Spacer()
        
        // MARK: - Translucent Card
        VStack(spacing: 0) {
          // Title & Subtitle
          VStack(spacing: 12) {
            Text(R.string.localizable.loginTitle())
              .font(.system(size: 32, weight: .bold))
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
            
            Text(R.string.localizable.loginSubtitleNew())
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.9))
              .multilineTextAlignment(.center)
          }
          .padding(.top, 32)
          .padding(.bottom, 28)
          
          // MARK: - Login Buttons
          VStack(spacing: 16) {
            // Apple Button
            Button(action: onApple) {
              HStack(spacing: 16) {
                Image(systemName: "applelogo")
                  .font(.system(size: 20, weight: .semibold))
                  .foregroundColor(.black)
                  .frame(width: 24)
                Text(R.string.localizable.loginApple())
                  .font(.system(size: 17, weight: .semibold))
                  .foregroundColor(.black)
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 28)
              .padding(.vertical, 18)
              .background(Color.white)
              .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(WelcomeButtonStyle())
            
            // Google Button
            Button(action: onGoogle) {
              HStack(spacing: 16) {
                Image(systemName: "g.circle.fill")
                  .font(.system(size: 20, weight: .medium))
                  .foregroundColor(.white)
                  .frame(width: 24)
                Text(R.string.localizable.loginGoogle())
                  .font(.system(size: 17, weight: .medium))
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 28)
              .padding(.vertical, 18)
              .background(Color.gray.opacity(0.4))
              .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(WelcomeButtonStyle())
            
            // Separator
            Text("OR")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.white.opacity(0.7))
              .padding(.vertical, 12)
            
            // Email Button
            Button(action: onEmail) {
              HStack(spacing: 16) {
                Image(systemName: "envelope")
                  .font(.system(size: 20, weight: .medium))
                  .foregroundColor(.white)
                  .frame(width: 24)
                Text(R.string.localizable.loginEmail())
                  .font(.system(size: 17, weight: .medium))
                  .foregroundColor(.white)
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 28)
              .padding(.vertical, 18)
              .background(Color.gray.opacity(0.4))
              .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(WelcomeButtonStyle())
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 24)
          
          // MARK: - Legal Text
          VStack(spacing: 6) {
            Text(R.string.localizable.loginFooterPrefix())
              .font(.system(size: 13, weight: .regular))
              .foregroundColor(.white.opacity(0.7))
              .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
              Button(action: onShowTerms) {
                Text(R.string.localizable.loginFooterTos())
                  .font(.system(size: 13, weight: .semibold))
                  .foregroundColor(.white)
                  .underline()
              }
              
              Text(R.string.localizable.loginFooterAnd())
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
              
              Button(action: onShowPrivacy) {
                Text(R.string.localizable.loginFooterPrivacy())
                  .font(.system(size: 13, weight: .semibold))
                  .foregroundColor(.white)
                  .underline()
              }
            }
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 32)
        }
        .padding(.horizontal, 20)
        .background(
          ZStack {
            RoundedRectangle(cornerRadius: 24)
              .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 24)
              .fill(Color.black.opacity(0.4))
          }
        )
        .padding(.horizontal, 20)
        
        Spacer()
        
        // MARK: - Signup Link
        Button(action: onSignup) {
          HStack(spacing: 4) {
            Text(R.string.localizable.loginNoAccount())
              .font(.system(size: 14, weight: .regular))
              .foregroundColor(.white.opacity(0.8))
            Text(R.string.localizable.authSignup())
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(.white)
          }
        }
        .padding(.bottom, 50)
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}
