//
//  LoginSecurityView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources
import UserNotifications
import Combine
@MainActor
final class LoginSecurityViewModel: ObservableObject {
    let engine: Engine
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var areNotificationsEnabled: Bool = false
    
    init(engine: Engine) {
        self.engine = engine
        Task {
            await checkNotificationStatus()
        }
    }
    
    func changePassword() async {
        // TODO: Implémenter le changement de mot de passe
        print("Change password")
    }
    
    func checkNotificationStatus() async {
        let status = await NotificationsManager.shared.authorizationStatus
        await MainActor.run {
            areNotificationsEnabled = status == .authorized
        }
    }
    
    func toggleNotifications() async {
        if areNotificationsEnabled {
            // Désactiver les notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            await MainActor.run {
                areNotificationsEnabled = false
            }
        } else {
            // Activer les notifications
            let granted = await NotificationsManager.shared.requestAuthorization()
            await MainActor.run {
                areNotificationsEnabled = granted
            }
        }
    }
}

struct LoginSecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: LoginSecurityViewModel
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    init(engine: Engine) {
        _vm = StateObject(wrappedValue: LoginSecurityViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Fond global clair
            Color(R.color.mainBackground.name)
                .ignoresSafeArea()
                // Bande noire qui va jusqu'en haut (sous la status bar)
                .overlay(
                    Color.black
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top),
                    alignment: .top
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header noir
                    header
                    
                    // Contenu
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Change password
                        changePasswordSection
                        
                        // MARK: - Two-factor auth
                        twoFactorSection
                        
                        // MARK: - Notifications
                        notificationsSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(R.string.localizable.settingsTitle())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(R.string.localizable.settingsSubtitle())
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
        .padding(.bottom, 1)
    }
    
    // MARK: - Change Password Section
    private var changePasswordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .font(.system(size: 18, weight: .semibold))
                Text(R.string.localizable.loginSecurityChangePasswordTitle())
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.loginSecurityCurrentPasswordLabel())
                        .font(.system(size: 14, weight: .semibold))
                    SecureField("", text: $vm.currentPassword)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.loginSecurityNewPasswordLabel())
                        .font(.system(size: 14, weight: .semibold))
                    SecureField("", text: $vm.newPassword)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.loginSecurityConfirmPasswordLabel())
                        .font(.system(size: 14, weight: .semibold))
                    SecureField("", text: $vm.confirmPassword)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            
            Button {
                Task { await vm.changePassword() }
            } label: {
                Text(R.string.localizable.loginSecurityChangePasswordButton())
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Two-Factor Section
    private var twoFactorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "shield")
                    .font(.system(size: 18, weight: .semibold))
                Text(R.string.localizable.loginSecurityTwoFactorTitle())
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(R.string.localizable.loginSecurityTwoFactorSmsLabel())
                    .font(.system(size: 14, weight: .semibold))
                
                Text(R.string.localizable.loginSecurityTwoFactorDescription())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
                Text(R.string.localizable.settingsNotificationsTitle())
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(R.string.localizable.settingsNotificationsDescription())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Toggle(isOn: Binding(
                get: { vm.areNotificationsEnabled },
                set: { _ in Task { await vm.toggleNotifications() } }
            )) {
                Text("Activer les notifications")
                    .font(.system(size: 15, weight: .medium))
            }
            .toggleStyle(SwitchToggleStyle(tint: .black))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
