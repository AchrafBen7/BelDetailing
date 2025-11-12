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
    VStack(alignment: .leading, spacing: 36) {

      // ← Bouton retour (localizable)
      Button(action: { dismiss() }) {
        HStack(spacing: 6) {
          Image(systemName: "chevron.left")
            .font(.system(size: 17, weight: .semibold))
          Text(R.string.localizable.commonBack()) // ← garde le localizable générique
            .font(.system(size: 17))
        }
        .foregroundColor(.gray)
      }
      .padding(.top, 8)
      .padding(.horizontal, 24)

      // MARK: - Titre + description
      VStack(alignment: .leading, spacing: 8) {
        // utilise ton style sectionTitle déjà présent
        R.string.localizable.signupRoleQuestion()
          .textView(style: AppStyle.TextStyle.sectionTitle)

        Text(R.string.localizable.signupRoleSubtitle()) // ex: "Select the type of user that best matches you."
          .font(.system(size: 17))
          .foregroundColor(.gray)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.horizontal, 30)
      .padding(.top, 10)
        

      // MARK: - Cartes de rôle
      VStack(spacing: 22) {
        ForEach(UserRole.allCases, id: \.self) { role in
          SignupRoleCard(role: role, isSelected: vm.selectedRole == role)
            .onTapGesture { vm.selectedRole = role }
            .animation(.easeInOut(duration: 0.2), value: vm.selectedRole)
        }
      }
      .padding(.horizontal, 30)
      .padding(.top, 10)

      Spacer()

      // MARK: - Bouton Continuer
      Button {
        if let selectedRole = vm.selectedRole { onContinue(selectedRole) }
      } label: {
        R.string.localizable.commonContinue().textView(style: .buttonCTA)
      }
      .buttonStyle(WelcomePrimaryButton())
      .disabled(vm.selectedRole == nil)
      .opacity(vm.selectedRole == nil ? 0.5 : 1)
      .padding(.horizontal, 30)
      .padding(.bottom, 60)
    }
    .padding(.horizontal, 24)
    .background(Color.white.ignoresSafeArea())
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
