//
//  SignupProviderFields.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct SignupProviderFields: View {
    @Binding var displayName: String
    @Binding var baseCity: String
    @Binding var postalCode: String
    @Binding var minPrice: Double
    @Binding var hasMobileService: Bool
    @Binding var companyName: String
    @Binding var bio: String
    var isDarkStyle: Bool = false
    
    var body: some View {
        VStack(spacing: 18) {
            // Informations professionnelles
            VStack(alignment: .leading, spacing: 16) {
                Text(R.string.localizable.signupSectionProfessional())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isDarkStyle ? .white.opacity(0.8) : .gray)
                    .padding(.bottom, 4)
                
                VStack(spacing: 18) {
                    BDInputField(
                        title: R.string.localizable.signupProviderDisplayName(),
                        placeholder: R.string.localizable.signupProviderDisplayNamePlaceholder(),
                        text: $displayName,
                        keyboard: .default,
                        isSecure: false,
                        icon: "person.circle",
                        showError: displayName.trimmingCharacters(in: .whitespaces).isEmpty && !displayName.isEmpty,
                        errorText: R.string.localizable.signupProviderDisplayNameRequired(),
                        isDarkStyle: isDarkStyle
                    )
                    
                    BDInputField(
                        title: R.string.localizable.signupCompanyNameOptional(),
                        placeholder: R.string.localizable.signupCompanyNameOptionalPlaceholder(),
                        text: $companyName,
                        keyboard: .default,
                        isSecure: false,
                        icon: "building.2",
                        showError: false,
                        errorText: "",
                        isDarkStyle: isDarkStyle
                    )
                    
                    // Bio (optionnel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(R.string.localizable.signupBioOptional())
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)
                        
                        ZStack(alignment: .topLeading) {
                            if bio.isEmpty {
                                Text(R.string.localizable.signupBioOptionalPlaceholder())
                                    .foregroundColor(isDarkStyle ? .white.opacity(0.5) : .gray.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $bio)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .foregroundColor(isDarkStyle ? .white : .black)
                        }
                        .background(isDarkStyle ? Color.white.opacity(0.15) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isDarkStyle ? Color.white.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Service mobile (toggle)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(R.string.localizable.signupMobileService())
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)
                        
                        HStack {
                            Text(R.string.localizable.signupMobileServiceToggle())
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(isDarkStyle ? .white : .black)
                            Spacer()
                            Toggle("", isOn: $hasMobileService)
                                .tint(isDarkStyle ? .white : .blue)
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
            }
            
            // Localisation
            VStack(alignment: .leading, spacing: 16) {
                Text(R.string.localizable.signupSectionLocation())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isDarkStyle ? .white.opacity(0.8) : .gray)
                    .padding(.bottom, 4)
                
                VStack(spacing: 18) {
                    BDInputField(
                        title: R.string.localizable.signupProviderCity(),
                        placeholder: R.string.localizable.signupProviderCityPlaceholder(),
                        text: $baseCity,
                        keyboard: .default,
                        isSecure: false,
                        icon: "mappin.circle",
                        showError: baseCity.trimmingCharacters(in: .whitespaces).isEmpty && !baseCity.isEmpty,
                        errorText: R.string.localizable.signupProviderCityRequired(),
                        isDarkStyle: isDarkStyle
                    )
                    
                    BDInputField(
                        title: R.string.localizable.signupProviderPostalCode(),
                        placeholder: R.string.localizable.signupProviderPostalCode(),
                        text: $postalCode,
                        keyboard: .numberPad,
                        isSecure: false,
                        icon: "number",
                        showError: postalCode.trimmingCharacters(in: .whitespaces).isEmpty && !postalCode.isEmpty,
                        errorText: R.string.localizable.signupProviderPostalCodeRequired(),
                        isDarkStyle: isDarkStyle
                    )
                }
            }
            
            // Tarification
            VStack(alignment: .leading, spacing: 16) {
                Text(R.string.localizable.signupSectionPricing())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isDarkStyle ? .white.opacity(0.8) : .gray)
                    .padding(.bottom, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(R.string.localizable.signupProviderMinPrice())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)
                    
                    HStack {
                        Button {
                            if minPrice > 0 {
                                minPrice = max(0, minPrice - 5)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(minPrice > 0 ? (isDarkStyle ? .white : .black) : (isDarkStyle ? .white.opacity(0.5) : .gray))
                        }
                        .disabled(minPrice <= 0)
                        
                        Text(String(format: "%.0f €", minPrice))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDarkStyle ? .white : .black)
                            .frame(minWidth: 80)
                        
                        Button {
                            minPrice += 5
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(isDarkStyle ? .white : .black)
                        }
                    }
                    .padding(16)
                    .background(isDarkStyle ? Color.white.opacity(0.15) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDarkStyle ? Color.white.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    
                    if minPrice <= 0 {
                        Text(R.string.localizable.signupProviderMinPriceError())
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
}

