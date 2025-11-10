//
//  SignupRoleSelectionView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//
//
//  SignupRoleSelectionView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//

import SwiftUI
import RswiftResources

// MARK: - View
struct SignupRoleSelectionView: View {
  @StateObject private var vm: SignupViewModel
  var onContinue: (UserRole) -> Void = { _ in }

  init(engine: Engine, onContinue: @escaping (UserRole) -> Void) {
    _vm = StateObject(wrappedValue: SignupViewModel(engine: engine))
    self.onContinue = onContinue
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 40) {
      // MARK: - Header
      VStack(spacing: 10) {
        Text("BelDetail")
          .font(.system(size: 40, weight: .bold))
          .foregroundColor(.black)

        Text(R.string.localizable.signupSubtitle())
          .font(.system(size: 20))
          .foregroundColor(.gray)
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.top, 50)

      // MARK: - Question
      R.string.localizable.signupRoleQuestion()
        .textView(style: AppStyle.TextStyle.sectionTitle)
        .padding(.horizontal, 30)

      // MARK: - Role Cards
      VStack(spacing: 22) {
        ForEach(UserRole.allCases, id: \.self) { role in
          SignupRoleCard(role: role, isSelected: vm.selectedRole == role)
            .onTapGesture { vm.selectedRole = role }
            .animation(.easeInOut(duration: 0.2), value: vm.selectedRole)
        }
      }
      .padding(.horizontal, 30)

      Spacer()

      // MARK: - Continue Button
      Button {
        if let selectedRole = vm.selectedRole {
          onContinue(selectedRole)
        }
      } label: {
        R.string.localizable.commonContinue()
          .textView(style: AppStyle.TextStyle.buttonCTA)
      }
      .buttonStyle(WelcomePrimaryButton())
      .disabled(vm.selectedRole == nil)
      .opacity(vm.selectedRole == nil ? 0.5 : 1)
      .padding(.horizontal, 30)
      .padding(.bottom, 60)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(false)
  }
}

// MARK: - Role Card
struct SignupRoleCard: View {
  let role: UserRole
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 18) {
      Image(systemName: icon(for: role))
        .font(.system(size: 28))
        .foregroundColor(.black)
        .frame(width: 56, height: 56)
        .background(Color.gray.opacity(0.08))
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text(title(for: role))
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(.black)
        Text(subtitle(for: role))
          .font(.system(size: 16))
          .foregroundColor(.gray)
      }

      Spacer()
    }
    .padding(.vertical, 22)
    .padding(.horizontal, 20)
    .background(Color.white)
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .stroke(isSelected ? Color.black : Color.gray.opacity(0.3),
                lineWidth: isSelected ? 2.5 : 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .shadow(color: .black.opacity(0.06), radius: 4, y: 3)
  }

  // MARK: - Text helpers
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
