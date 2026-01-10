//
//  SignupCompanyInfoSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupCompanyInfoSection: View {
    let role: UserRole
    
    // Company bindings
    @Binding var companyLegalName: String
    @Binding var companyTypeId: CompanyType?
    @Binding var companyCity: String
    @Binding var companyPostalCode: String
    @Binding var companyContactName: String
    
    // Provider bindings
    @Binding var providerDisplayName: String
    @Binding var providerCompanyName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "building.2")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Informations entreprise")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            // Champs
            if role == .company {
                SignupCompanyFields(
                    legalName: $companyLegalName,
                    companyTypeId: $companyTypeId,
                    city: $companyCity,
                    postalCode: $companyPostalCode,
                    contactName: $companyContactName,
                    isDarkStyle: true
                )
            } else if role == .provider {
                VStack(spacing: 20) {
                    BDInputField(
                        title: "Nom de l'entreprise",
                        placeholder: "Nom légal de l'entreprise",
                        text: $providerCompanyName,
                        keyboard: .default,
                        isSecure: false,
                        icon: "building.2",
                        showError: false,
                        errorText: "",
                        isDarkStyle: true
                    )
                    
                    BDInputField(
                        title: "Nom d'affichage",
                        placeholder: "Nom d'affichage (visible par les clients)",
                        text: $providerDisplayName,
                        keyboard: .default,
                        isSecure: false,
                        icon: "person.circle",
                        showError: providerDisplayName.trimmingCharacters(in: .whitespaces).isEmpty && !providerDisplayName.isEmpty,
                        errorText: "Nom d'affichage requis",
                        isDarkStyle: true
                    )
                }
            }
        }
    }
}

