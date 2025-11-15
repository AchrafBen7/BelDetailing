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
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if vm.isLoading {
                        LoadingView()
                    } else if let user = vm.user {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 24) {
                                
                                // MARK: - Groot schermtitel
                                Text(R.string.localizable.profileTitle() + ".")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.top, 8)
                                
                                // MARK: - Hoofd kaart met avatar + naam
                                ProfileSummaryCard(
                                    user: user,
                                    subtitle: R.string.localizable.profileHeaderSubtitle()
                                ) {
                                    // TODO: navigatie naar detailprofiel
                                    // bv. vm.openProfileDetails()
                                    print("Profile tapped")
                                }
                                
                                // MARK: - Sectietitel "Settings"
                                Text(R.string.localizable.profileSettingsTitle())
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.top, 8)
                                
                                VStack(spacing: 12) {
                                    // MARK: - Settings cards
                                    
                                    NavigationLink {
                                        Text("Orders WIP")
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "doc.text",
                                            title: R.string.localizable.profileSettingsOrders()
                                        )
                                    }
                                    
                                    NavigationLink {
                                        Text("Payments & Payouts WIP")
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "creditcard",
                                            title: R.string.localizable.profileSettingsPaymentsPayouts()
                                        )
                                    }
                                    
                                    NavigationLink {
                                        Text("Taxes WIP")
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "doc.plaintext",
                                            title: R.string.localizable.profileSettingsTaxes()
                                        )
                                    }
                                    
                                    NavigationLink {
                                        Text("Login & Security WIP")
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "lock.shield",
                                            title: R.string.localizable.profileSettingsLoginSecurity()
                                        )
                                    }
                                }
                                
                                // MARK: - Logout
                                Button(role: .destructive) {
                                    vm.logout()
                                } label: {
                                    Text(R.string.localizable.logout())
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                }
                                .buttonStyle(.borderless)
                                .padding(.top, 16)
                                
                                Spacer(minLength: 20)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    } else {
                        EmptyStateView(
                            title: R.string.localizable.profileNotLoggedTitle(),
                            message: R.string.localizable.profileNotLoggedMessage()
                        )
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            await vm.load()
        }
        .alert(vm.errorText ?? "",
               isPresented: .constant(vm.errorText != nil)) {
            Button(R.string.localizable.commonOk(), role: .cancel) {
                vm.errorText = nil
            }
        }
    }
}

#Preview {
    ProfileView(engine: Engine(mock: true))
}
