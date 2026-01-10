//
//  SignupCustomerInfoSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct SignupCustomerInfoSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var vehicleType: VehicleType?
    @Binding var address: String
    var isDarkStyle: Bool = true // Always dark style for unified design

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "person.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Informations personnelles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)

            // Fields
            SignupCustomerFields(
                firstName: $firstName,
                lastName: $lastName,
                vehicleType: $vehicleType,
                address: $address,
                isDarkStyle: isDarkStyle
            )
        }
    }
}

