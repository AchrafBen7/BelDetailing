//
//  SignupCustomerFields.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct SignupCustomerFields: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var vehicleType: VehicleType?
    @Binding var address: String
    var isDarkStyle: Bool = false
    
    var body: some View {
        VStack(spacing: 18) {
            // Firstname EN PREMIER
            BDInputField(
                title: R.string.localizable.signupCustomerFirstName(),
                placeholder: R.string.localizable.signupCustomerFirstNamePlaceholder(),
                text: $firstName,
                keyboard: .default,
                isSecure: false,
                icon: "person",
                showError: firstName.trimmingCharacters(in: .whitespaces).isEmpty && !firstName.isEmpty,
                errorText: R.string.localizable.signupFirstNameRequired(),
                isDarkStyle: isDarkStyle
            )
            
            // Lastname EN DEUXIÈME
            BDInputField(
                title: R.string.localizable.signupCustomerLastName(),
                placeholder: R.string.localizable.signupCustomerLastNamePlaceholder(),
                text: $lastName,
                keyboard: .default,
                isSecure: false,
                icon: "person",
                showError: lastName.trimmingCharacters(in: .whitespaces).isEmpty && !lastName.isEmpty,
                errorText: R.string.localizable.signupLastNameRequired(),
                isDarkStyle: isDarkStyle
            )
            
            // Type de véhicule EN TROISIÈME - Sélection visuelle avec images
            VStack(alignment: .leading, spacing: 12) {
                Text(R.string.localizable.signupVehicleType())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)
                
                // Grille de sélection avec images
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(VehicleType.allCases) { vehicleTypeOption in
                        VehicleTypeCard(
                            vehicleType: vehicleTypeOption,
                            isSelected: vehicleType == vehicleTypeOption,
                            isDarkStyle: isDarkStyle
                        ) {
                            vehicleType = vehicleTypeOption
                        }
                    }
                }
            }
            
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
                isDarkStyle: isDarkStyle
            )
        }
    }
}

