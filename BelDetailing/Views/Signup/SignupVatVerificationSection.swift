//
//  SignupVatVerificationSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupVatVerificationSection: View {
    let role: UserRole
    let engine: Engine
    
    @Binding var vatNumber: String
    @Binding var vatLookupResult: VatLookupResponse?
    @Binding var isVerifyingVAT: Bool
    @Binding var vatVerificationError: String?
    
    // Company bindings
    @Binding var companyLegalName: String
    @Binding var companyCity: String
    @Binding var companyPostalCode: String
    
    // Provider bindings
    @Binding var providerBaseCity: String
    @Binding var providerPostalCode: String
    @Binding var providerCompanyName: String
    
    private var vatStrokeColor: Color {
        if vatLookupResult?.valid == true {
            return Color.green.opacity(0.6)
        } else if vatVerificationError != nil {
            return Color.red.opacity(0.6)
        } else {
            return Color.white.opacity(0.3)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec icône
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.green)
                Text("Vérification TVA")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            Text("Entrez votre numéro pour valider votre entreprise")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 16)
            
            // Input field avec bouton intégré
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField("Numéro de TVA", text: $vatNumber)
                    .keyboardType(.default)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .onChange(of: vatNumber) { _, _ in
                        vatLookupResult = nil
                        vatVerificationError = nil
                    }
                
                Button {
                    verifyVAT()
                } label: {
                    if isVerifyingVAT {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(vatNumber.isEmpty ? Color.white.opacity(0.12) : Color.orange)
                )
                .disabled(isVerifyingVAT || vatNumber.isEmpty)
                .opacity(vatNumber.isEmpty ? 0.5 : 1.0)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(vatStrokeColor, lineWidth: 2)
                    )
            )
            
            // Résultat de validation (carte verte simplifiée)
            if let result = vatLookupResult, result.valid {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        if let companyName = result.companyName {
                            Text(companyName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        if let address = result.address {
                            Text(address.replacingOccurrences(of: "\n", with: " "))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    
                    Spacer()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green.opacity(0.15))
                )
                .padding(.top, 8)
            }
            
            // Message d'erreur
            if let error = vatVerificationError {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                    Text(error)
                        .font(.system(size: 15))
                        .foregroundColor(.red.opacity(0.9))
                }
                .padding(.top, 12)
            }
        }
    }
    
    private func verifyVAT() {
        guard !vatNumber.isEmpty else { return }
        
        isVerifyingVAT = true
        vatLookupResult = nil
        vatVerificationError = nil
        
        Task {
            let response = await engine.userService.lookupVAT(vatNumber)
            
            await MainActor.run {
                isVerifyingVAT = false
                
                switch response {
                case .success(let lookup):
                    if lookup.valid {
                        vatLookupResult = lookup
                        vatVerificationError = nil
                        
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
                        vatLookupResult = nil
                        vatVerificationError = lookup.error ?? "Numéro de TVA non reconnu en Belgique"
                    }
                    
                case .failure(let error):
                    vatLookupResult = nil
                    vatVerificationError = "Erreur lors de la vérification. Veuillez réessayer."
                    print("❌ [VAT] Lookup error: \(error.localizedDescription)")
                }
            }
        }
    }
}

