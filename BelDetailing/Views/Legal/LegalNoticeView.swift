//
//  LegalNoticeView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct LegalNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Mentions Légales")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Sections
                    section(
                        title: "Éditeur",
                        content: """
                        \(LegalInfo.legalName)
                        \(LegalInfo.address)
                        
                        Email : \(LegalInfo.supportEmail)
                        \(LegalInfo.supportPhone != nil ? "Téléphone : \(LegalInfo.supportPhone!)" : "")
                        \(LegalInfo.companyNumber != nil ? "Numéro d'entreprise : \(LegalInfo.companyNumber!)" : "")
                        \(LegalInfo.vatNumber != nil ? "TVA : \(LegalInfo.vatNumber!)" : "")
                        """
                    )
                    
                    section(
                        title: "Directeur de Publication",
                        content: """
                        \(LegalInfo.directorName ?? "Non spécifié")
                        """
                    )
                    
                    section(
                        title: "Hébergeur",
                        content: """
                        \(LegalInfo.hostName)
                        \(LegalInfo.hostAddress)
                        \(LegalInfo.hostPhone != nil ? "Téléphone : \(LegalInfo.hostPhone!)" : "")
                        """
                    )
                    
                    section(
                        title: "Traitement des Données",
                        content: """
                        Les données personnelles collectées sont traitées conformément au RGPD.
                        
                        Responsable du traitement : \(LegalInfo.legalName)
                        \(LegalInfo.dpoEmail != nil ? "Délégué à la protection des données : \(LegalInfo.dpoEmail!)" : "")
                        
                        Pour exercer vos droits (accès, rectification, suppression), contactez-nous à : \(LegalInfo.supportEmail)
                        """
                    )
                    
                    section(
                        title: "Propriété Intellectuelle",
                        content: """
                        L'ensemble du contenu de l'application (textes, images, logos, design) est la propriété exclusive de NIOS, sauf mention contraire.
                        
                        Toute reproduction, même partielle, est interdite sans autorisation préalable.
                        """
                    )
                    
                    section(
                        title: "Cookies",
                        content: """
                        Notre application mobile n'utilise pas de cookies web traditionnels. Nous utilisons des technologies similaires pour améliorer votre expérience (identifiants d'appareil, tokens de session).
                        """
                    )
                }
                .padding(20)
            }
            .navigationTitle("Mentions Légales")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tabBarVisibility.isHidden = true
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
            }
        }
    }
    
    private func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
    }
}

