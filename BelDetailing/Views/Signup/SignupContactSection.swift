//
//  SignupContactSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupContactSection: View {
    let role: UserRole
    @Binding var phone: String
    @Binding var vatNumber: String
    let isPhoneValid: Bool
    let isVatValid: Bool
    let engine: Engine
    
    // Company bindings
    @Binding var companyLegalName: String
    @Binding var companyCity: String
    @Binding var companyPostalCode: String
    
    // Provider bindings
    @Binding var providerBaseCity: String
    @Binding var providerPostalCode: String
    @Binding var providerCompanyName: String
    
    @State private var isVerifyingVAT = false
    @State private var vatVerificationMessage: String? = nil
    @State private var vatVerificationSuccess = false

    private var vatStrokeColor: Color {
        if vatVerificationSuccess { return Color.green.opacity(0.6) }
        if !isVatValid && !vatNumber.isEmpty { return Color.red.opacity(0.6) }
        return Color.white.opacity(0.3)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "phone")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Contact")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 20) {
                BDInputField(
                    title: "Téléphone",
                    placeholder: "Numéro de téléphone",
                    text: $phone,
                    keyboard: .phonePad,
                    isSecure: false,
                    icon: "phone",
                    showError: !isPhoneValid && !phone.isEmpty,
                    errorText: "Numéro invalide",
                    isDarkStyle: true
                )
                if role == .company || role == .provider {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TVA")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 24)
                            
                            TextField("Numéro de TVA", text: $vatNumber)
                                .keyboardType(.default)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .onChange(of: vatNumber) { _, _ in
                                    vatVerificationMessage = nil
                                    vatVerificationSuccess = false
                                }
                            
                            Button {
                                verifyVAT()
                            } label: {
                                if isVerifyingVAT {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Vérifier")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 80, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(vatNumber.isEmpty ? Color.white.opacity(0.2) : Color.orange.opacity(0.8))
                            )
                            .disabled(isVerifyingVAT || vatNumber.isEmpty)
                            .opacity(vatNumber.isEmpty ? 0.5 : 1.0)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(vatStrokeColor, lineWidth: 1)
                                )
                        )
                        
                        if let message = vatVerificationMessage {
                            HStack(spacing: 6) {
                                Image(systemName: vatVerificationSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundColor(vatVerificationSuccess ? .green : .red)
                                    .font(.system(size: 14))
                                Text(message)
                                    .font(.system(size: 13))
                                    .foregroundColor(vatVerificationSuccess ? .green.opacity(0.9) : .red.opacity(0.9))
                            }
                            .padding(.top, 4)
                        }
                        
                        if !isVatValid && !vatNumber.isEmpty && vatVerificationMessage == nil {
                            Text("TVA invalide")
                                .font(.system(size: 13))
                                .foregroundColor(.red.opacity(0.9))
                                .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }
    
    private func verifyVAT() {
        guard !vatNumber.isEmpty else { return }
        
        isVerifyingVAT = true
        vatVerificationMessage = nil
        vatVerificationSuccess = false
        
        Task {
            let response = await engine.userService.lookupVAT(vatNumber)
            
            await MainActor.run {
                isVerifyingVAT = false
                
                switch response {
                case .success(let lookup):
                    if lookup.valid {
                        vatVerificationSuccess = true
                        vatVerificationMessage = "Entreprise trouvée. Informations pré-remplies."
                        
                        if role == .company {
                            if let companyName = lookup.companyName, !companyName.isEmpty {
                                companyLegalName = companyName
                            }
                            if let city = lookup.city, !city.isEmpty {
                                companyCity = city
                            }
                            if let postalCode = lookup.postalCode, !postalCode.isEmpty {
                                companyPostalCode = postalCode
                            }
                        } else if role == .provider {
                            if let companyName = lookup.companyName, !companyName.isEmpty {
                                providerCompanyName = companyName
                            }
                            if let city = lookup.city, !city.isEmpty {
                                providerBaseCity = city
                            }
                            if let postalCode = lookup.postalCode, !postalCode.isEmpty {
                                providerPostalCode = postalCode
                            }
                        }
                    } else {
                        vatVerificationSuccess = false
                        vatVerificationMessage = lookup.error ?? "Numéro de TVA non reconnu en Belgique"
                    }
                    
                case .failure(let error):
                    vatVerificationSuccess = false
                    vatVerificationMessage = "Erreur lors de la vérification. Veuillez réessayer."
                    print("❌ [VAT] Lookup error: \(error.localizedDescription)")
                }
            }
        }
    }
}

