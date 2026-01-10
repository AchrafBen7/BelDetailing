//
//  SignupCompanyFields.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct SignupCompanyFields: View {
    @Binding var legalName: String
    @Binding var companyTypeId: CompanyType?
    @Binding var city: String
    @Binding var postalCode: String
    @Binding var contactName: String
    var isDarkStyle: Bool = false
    
    var body: some View {
        VStack(spacing: 18) {
            // Type d'entreprise EN PREMIER
            VStack(alignment: .leading, spacing: 8) {
                Text(R.string.localizable.signupCompanyType())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)
                
                Menu {
                    ForEach(CompanyType.allCases) { companyTypeOption in
                        Button {
                            companyTypeId = companyTypeOption
                        } label: {
                            HStack {
                                Text(companyTypeOption.localizedName)
                                if companyTypeId == companyTypeOption {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let selectedCompanyType = companyTypeId {
                            Text(selectedCompanyType.localizedName)
                                .foregroundColor(.black)
                        } else {
                            Text(R.string.localizable.signupSelectCompanyType())
                                .foregroundColor(isDarkStyle ? .white.opacity(0.6) : .gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(isDarkStyle ? .white.opacity(0.7) : .gray)
                    }
                    .padding(16)
                    .background(isDarkStyle ? Color.white.opacity(0.15) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDarkStyle ? Color.white.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
            }
            
            BDInputField(
                title: R.string.localizable.signupCompanyLegalName(),
                placeholder: R.string.localizable.signupCompanyLegalNamePlaceholder(),
                text: $legalName,
                keyboard: .default,
                isSecure: false,
                icon: "building.2",
                showError: legalName.trimmingCharacters(in: .whitespaces).isEmpty && !legalName.isEmpty,
                errorText: R.string.localizable.signupCompanyLegalNameRequired(),
                isDarkStyle: isDarkStyle
            )
            
            // Champs optionnels
            BDInputField(
                title: R.string.localizable.signupCityOptional(),
                placeholder: R.string.localizable.signupCityOptionalPlaceholder(),
                text: $city,
                keyboard: .default,
                isSecure: false,
                icon: "mappin.circle",
                showError: false,
                errorText: "",
                isDarkStyle: isDarkStyle
            )
            
            BDInputField(
                title: R.string.localizable.signupPostalCodeOptional(),
                placeholder: "Code postal",
                text: $postalCode,
                keyboard: .numberPad,
                isSecure: false,
                icon: "number",
                showError: false,
                errorText: "",
                isDarkStyle: isDarkStyle
            )
            
            BDInputField(
                title: R.string.localizable.signupContactNameOptional(),
                placeholder: R.string.localizable.signupContactNameOptionalPlaceholder(),
                text: $contactName,
                keyboard: .default,
                isSecure: false,
                icon: "person.circle",
                showError: false,
                errorText: "",
                isDarkStyle: isDarkStyle
            )
        }
    }
}

