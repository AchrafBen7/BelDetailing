//
//  SignupPresentationSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct SignupPresentationSection: View {
    @Binding var providerBio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Présentation")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            Text("Optionnel - Décrivez votre activité")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.65))
                .padding(.bottom, 12)
            
            // TextEditor
            ZStack(alignment: .topLeading) {
                TextEditor(text: $providerBio)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .frame(minHeight: 140)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                    )
                    .scrollContentBackground(.hidden)
                
                if providerBio.isEmpty {
                    Text("Décrivez vos services, votre expérience, vos spécialités...")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.leading, 20)
                        .padding(.top, 24)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

