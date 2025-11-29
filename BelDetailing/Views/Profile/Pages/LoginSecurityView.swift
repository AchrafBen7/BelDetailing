//  LoginSecurityView.swift

import SwiftUI
import RswiftResources
import Combine

@MainActor
final class LoginSecurityViewModel: ObservableObject {
    private let engine: Engine
    
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isTwoFactorEnabled: Bool = false
    
    init(engine: Engine) {
        self.engine = engine
        // plus tard: charger la vraie valeur 2FA depuis l’API
    }
    
    func changePassword() async {
        // plus tard: appeler un endpoint /update-password
        print("Change password…")
    }
}

struct LoginSecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: LoginSecurityViewModel
    
    init(engine: Engine) {
        _vm = StateObject(wrappedValue: LoginSecurityViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.loginSecurityTitle())
                            .font(.system(size: 28, weight: .bold))
                        Text(R.string.localizable.loginSecuritySubtitle())
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                    
                    // MARK: - Change password
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
                    
                    // MARK: - Two-factor auth
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
                            
                            Toggle("", isOn: $vm.isTwoFactorEnabled)
                                .labelsHidden()
                                .padding(.top, 4)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 8)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
