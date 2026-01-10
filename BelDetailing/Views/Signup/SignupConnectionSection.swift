//
//  SignupConnectionSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupConnectionSection: View {
    @Binding var email: String
    @Binding var password: String
    let isEmailValid: Bool
    let isPasswordValid: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Connexion")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 20) {
                BDInputField(
                    title: "Email",
                    placeholder: "nom@domaine.com",
                    text: $email,
                    keyboard: .emailAddress,
                    icon: "envelope",
                    showError: !email.isValidEmail && !email.isEmpty,
                    errorText: "Email invalide",
                    isDarkStyle: true
                )
                BDInputField(
                    title: "Mot de passe",
                    placeholder: "Votre mot de passe",
                    text: $password,
                    keyboard: .default,
                    isSecure: true,
                    icon: "lock",
                    showError: !isPasswordValid && !password.isEmpty,
                    errorText: "Mot de passe trop court",
                    isDarkStyle: true
                )
            }
        }
    }
}

