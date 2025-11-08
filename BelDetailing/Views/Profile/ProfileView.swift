//
//  ProfileView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct ProfileView: View {
  @StateObject private var vm: ProfileViewModel

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: ProfileViewModel(engine: engine))
  }

  var body: some View {
    NavigationView {
      Group {
        if vm.isLoading {
          LoadingView()
        } else if let user = vm.user {
          List {
            Section(R.string.localizable.profileSectionAccount()) {
              Text(user.email).textView(style: .description)
              Text(user.role.rawValue.capitalized).textView(style: .description)
              if let vat = user.vatNumber {
                Text("TVA: \(vat)").textView(style: .description)
              }
            }
            Section(R.string.localizable.profileSectionSettings()) {
              NavigationLink(R.string.localizable.profilePayments()) { Text("Payments WIP") }
              NavigationLink(R.string.localizable.profileNotifications()) { Text("Notifications WIP") }
              NavigationLink(R.string.localizable.profileHelpSupport()) { Text("Help & Support WIP") }
            }
            Section {
              Button(role: .destructive) { vm.logout() } label: {
                Text(R.string.localizable.logout())
              }
            }
          }
          .listStyle(.insetGrouped)
        } else {
          EmptyStateView(title: R.string.localizable.profileNotLoggedTitle(),
                         message: R.string.localizable.profileNotLoggedMessage())
        }
      }
      .navigationTitle(R.string.localizable.tabProfile())
    }
    .task { await vm.load() }
    .alert(vm.errorText ?? "", isPresented: .constant(vm.errorText != nil)) {
      Button(R.string.localizable.ok(), role: .cancel) { vm.errorText = nil }
    }
  }
}

#Preview { ProfileView(engine: Engine(mock: true)) }
