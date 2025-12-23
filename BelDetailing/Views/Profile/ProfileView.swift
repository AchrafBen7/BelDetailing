//  ProfileView.swift

import SwiftUI
import RswiftResources

struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel
    private let engine: Engine           // 👈 on garde l’engine pour pousser les vues
    
    init(engine: Engine) {
        self.engine = engine
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
                                    .textView(style: .heroTitle, color: .black)
                                    .padding(.top, 8)
                                
                                // MARK: - Hoofd kaart met avatar + naam
                                ProfileSummaryCard(
                                    user: user,
                                    subtitle: R.string.localizable.profileHeaderSubtitle()
                                ) {
                                    // Plus tard: détail du profil
                                    print("Profile tapped")
                                }
                                
                                // MARK: - Sectietitel "Settings"
                                Text(R.string.localizable.profileSettingsTitle())
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.top, 8)
                                
                                VStack(spacing: 12) {
                                    // MARK: - My Orders -> BookingsView
                                    NavigationLink {
                                        BookingsView(engine: engine)
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "doc.text",
                                            title: R.string.localizable.profileSettingsOrders()
                                        )
                                    }
                                    
                                    // MARK: - Payments & payouts
                                    NavigationLink {
                                        PaymentSettingsView(engine: engine)
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "creditcard",
                                            title: R.string.localizable.profileSettingsPaymentsPayouts()
                                        )
                                    }

                                    // MARK: - Taxes
                                    NavigationLink {
                                        TaxesView(engine: engine)
                                    } label: {
                                        ProfileSettingRow(
                                            systemIcon: "doc.plaintext",
                                            title: R.string.localizable.profileSettingsTaxes()
                                        )
                                    }
                                    
                                    // MARK: - Login & Security
                                    NavigationLink {
                                        LoginSecurityView(engine: engine)
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
