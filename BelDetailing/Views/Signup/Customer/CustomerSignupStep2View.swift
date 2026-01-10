//
//  CustomerSignupStep2View.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct CustomerSignupStep2View: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var address: String
    @Binding var email: String
    @Binding var phone: String
    @Binding var password: String
    
    let vehicleType: VehicleType
    let onBack: () -> Void
    let onSubmit: () -> Void
    let onLogin: () -> Void
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".") &&
        phone.count >= 8 &&
        password.count >= 6
    }
    
    var body: some View {
        ZStack {
            // Fond avec image
            GeometryReader { geometry in
                Image("launchImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.65))
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Bouton retour
                HStack {
                    Button(action: onBack) {
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
                
                // Carte avec formulaire
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Titre
                        titleSection
                            .padding(.bottom, 32)
                        
                        // Champs du formulaire
                        formFields
                        
                        // Bouton submit
                        submitButton
                            .padding(.top, 32)
                        
                        // Lien login
                        loginLink
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .background(cardBackground)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Informations personnelles")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Complétez votre profil")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Form Fields
    
    private var formFields: some View {
        VStack(spacing: 18) {
            // Prénom
            BDInputField(
                title: R.string.localizable.signupCustomerFirstName(),
                placeholder: R.string.localizable.signupCustomerFirstNamePlaceholder(),
                text: $firstName,
                keyboard: .default,
                isSecure: false,
                icon: "person",
                showError: firstName.trimmingCharacters(in: .whitespaces).isEmpty && !firstName.isEmpty,
                errorText: R.string.localizable.signupFirstNameRequired(),
                isDarkStyle: true
            )
            
            // Nom
            BDInputField(
                title: R.string.localizable.signupCustomerLastName(),
                placeholder: R.string.localizable.signupCustomerLastNamePlaceholder(),
                text: $lastName,
                keyboard: .default,
                isSecure: false,
                icon: "person",
                showError: lastName.trimmingCharacters(in: .whitespaces).isEmpty && !lastName.isEmpty,
                errorText: R.string.localizable.signupLastNameRequired(),
                isDarkStyle: true
            )
            
            // Adresse (optionnel)
            BDInputField(
                title: R.string.localizable.signupAddressOptional(),
                placeholder: R.string.localizable.signupAddressOptionalPlaceholder(),
                text: $address,
                keyboard: .default,
                isSecure: false,
                icon: "mappin.circle",
                showError: false,
                errorText: "",
                isDarkStyle: true
            )
            
            // Email
            BDInputField(
                title: "Email",
                placeholder: "votre@email.com",
                text: $email,
                keyboard: .emailAddress,
                isSecure: false,
                icon: "envelope",
                showError: !email.isEmpty && !email.contains("@"),
                errorText: "Email invalide",
                isDarkStyle: true
            )
            
            // Téléphone
            BDInputField(
                title: "Téléphone",
                placeholder: "+32 470 12 34 56",
                text: $phone,
                keyboard: .phonePad,
                isSecure: false,
                icon: "phone",
                showError: !phone.isEmpty && phone.count < 8,
                errorText: "Téléphone invalide",
                isDarkStyle: true
            )
            
            // Mot de passe
            BDInputField(
                title: "Mot de passe",
                placeholder: "Minimum 6 caractères",
                text: $password,
                keyboard: .default,
                isSecure: true,
                icon: "lock",
                showError: !password.isEmpty && password.count < 6,
                errorText: "Minimum 6 caractères",
                isDarkStyle: true
            )
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: onSubmit) {
            Text("Créer mon compte")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color.orange : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isFormValid)
    }
    
    // MARK: - Login Link
    
    private var loginLink: some View {
        HStack {
            Text("Déjà un compte ?")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
            
            Button("Se connecter") {
                onLogin()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

