//
//  UserInfoSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
//  UserInfoSection.swift

import SwiftUI
import RswiftResources

extension BookingStep2View {

    var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // TITLE
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Informations personnelles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

            // FULL NAME
            inputField(
                title: "NOM COMPLET",
                text: $fullName,
                placeholder: "Jean Dupont"
            )

            // PHONE
            inputField(
                title: "TÉLÉPHONE",
                text: $phone,
                placeholder: "+32 2 123 45 67",
                keyboard: .phonePad
            )

            // EMAIL
            inputField(
                title: "EMAIL",
                text: $email,
                placeholder: "jean.dupont@email.com",
                keyboard: .emailAddress
            )
            
            // ADDRESS
            inputField(
                title: "ADRESSE",
                text: $address,
                placeholder: "Rue de la Paix 123, 1000 Bruxelles"
            )

            // NOTES (OPTIONAL)
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTES (OPTIONNEL)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Instructions particulières, accès...")
                            .foregroundColor(.gray)
                            .padding(.leading, 16)
                            .padding(.top, 20)
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
}
