//
//  SignupRoleSelectionView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//

import SwiftUI
import RswiftResources

struct SignupRoleSelectionView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var vm: SignupViewModel
  var onContinue: (UserRole) -> Void = { _ in }

  init(engine: Engine, onContinue: @escaping (UserRole) -> Void) {
    _vm = StateObject(wrappedValue: SignupViewModel(engine: engine))
    self.onContinue = onContinue
  }

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
          Button(action: { dismiss() }) {
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
            Text(R.string.localizable.signupRoleQuestion())
              .font(.system(size: 32, weight: .bold))
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
            
            Text(R.string.localizable.signupRoleSubtitle())
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.9))
              .multilineTextAlignment(.center)
          }
          .padding(.top, 32)
          .padding(.bottom, 28)
          
          // MARK: - Role Cards
          VStack(spacing: 16) {
            ForEach(UserRole.allCases, id: \.self) { role in
              SignupRoleCard(role: role, isSelected: vm.selectedRole == role)
                .onTapGesture {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    vm.selectedRole = role
                  }
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
        
        // MARK: - Continue Button
        Button {
          if let selectedRole = vm.selectedRole {
            onContinue(selectedRole)
          }
        } label: {
          Text(R.string.localizable.commonContinue())
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .disabled(vm.selectedRole == nil)
        .opacity(vm.selectedRole == nil ? 0.5 : 1.0)
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
        .buttonStyle(WelcomeButtonStyle())
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

// MARK: - Role Card
struct SignupRoleCard: View {
  let role: UserRole
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 18) {
      Image(systemName: icon(for: role))
        .font(.system(size: 28, weight: .medium))
        .foregroundColor(.white)
        .frame(width: 56, height: 56)
        .background(Color.white.opacity(0.2))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text(title(for: role))
          .font(.system(size: 18, weight: .semibold))
          .foregroundColor(.white)
        Text(subtitle(for: role))
          .font(.system(size: 14, weight: .regular))
          .foregroundColor(.white.opacity(0.8))
      }

      Spacer()
      
      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.white)
      }
    }
    .padding(.vertical, 20)
    .padding(.horizontal, 20)
    .background(
      RoundedRectangle(cornerRadius: 18)
        .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 18)
            .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2),
                    lineWidth: isSelected ? 2 : 1)
        )
    )
  }

  // MARK: - Helpers
  private func icon(for role: UserRole) -> String {
    switch role {
    case .customer: return "person"
    case .company:  return "building.2"
    case .provider: return "briefcase"
    }
  }

  private func title(for role: UserRole) -> String {
    switch role {
    case .customer: return R.string.localizable.signupRoleCustomerTitle()
    case .company:  return R.string.localizable.signupRoleCompanyTitle()
    case .provider: return R.string.localizable.signupRoleProviderTitle()
    }
  }

  private func subtitle(for role: UserRole) -> String {
    switch role {
    case .customer: return R.string.localizable.signupRoleCustomerSubtitle()
    case .company:  return R.string.localizable.signupRoleCompanySubtitle()
    case .provider: return R.string.localizable.signupRoleProviderSubtitle()
    }
  }
}
