//
//  SignupContactSecuritySection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupContactSecuritySection: View {
    @Binding var email: String
    @Binding var phone: String
    @Binding var password: String
    
    let isEmailValid: Bool
    let isPhoneValid: Bool
    let isPasswordValid: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Contact & Sécurité")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            // Champs
            VStack(spacing: 20) {
                BDInputField(
                    title: "Email professionnel",
                    placeholder: "Email professionnel",
                    text: $email,
                    keyboard: .emailAddress,
                    isSecure: false,
                    icon: "envelope",
                    showError: !isEmailValid && !email.isEmpty,
                    errorText: "Email invalide",
                    isDarkStyle: true
                )
                
                BDInputField(
                    title: "Téléphone",
                    placeholder: "+32 XXX XX XX XX",
                    text: $phone,
                    keyboard: .phonePad,
                    isSecure: false,
                    icon: "phone",
                    showError: !isPhoneValid && !phone.isEmpty,
                    errorText: "Numéro invalide",
                    isDarkStyle: true
                )
                
                BDInputField(
                    title: "Mot de passe",
                    placeholder: "Mot de passe (min. 8 caractères)",
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

