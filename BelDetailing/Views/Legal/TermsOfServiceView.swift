//
//  TermsOfServiceView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Conditions Générales d'Utilisation")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 8)
                    
                    Text("Dernière mise à jour : 1er janvier 2026")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Sections
                    section(
                        title: "1. Acceptation des Conditions",
                        content: """
                        En utilisant l'application NIOS, vous acceptez d'être lié par ces Conditions Générales d'Utilisation. Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'application.
                        """
                    )
                    
                    section(
                        title: "2. Description du Service",
                        content: """
                        NIOS est une plateforme de mise en relation entre :
                        
                        • Clients : propriétaires de véhicules cherchant des services de nettoyage
                        • Prestataires : professionnels offrant des services de nettoyage automobile
                        • Entreprises : sociétés recherchant des prestataires pour des contrats
                        
                        NIOS facilite la réservation, le paiement et le suivi des services, mais n'est pas responsable de la qualité des services fournis par les prestataires.
                        """
                    )
                    
                    section(
                        title: "3. Compte Utilisateur",
                        content: """
                        Pour utiliser NIOS, vous devez :
                        
                        • Créer un compte avec des informations exactes
                        • Maintenir la sécurité de votre compte
                        • Être âgé d'au moins 18 ans
                        • Ne pas partager votre compte avec d'autres personnes
                        • Nous notifier immédiatement de toute utilisation non autorisée
                        """
                    )
                    
                    section(
                        title: "4. Rôles et Responsabilités",
                        content: """
                        Clients :
                        • Fournir des informations exactes sur le véhicule et l'adresse
                        • Être présent ou accessible au moment du service
                        • Payer les services réservés
                        
                        Prestataires :
                        • Fournir des services professionnels de qualité
                        • Respecter les horaires convenus
                        • Maintenir les assurances et certifications nécessaires
                        • Compléter le profil avec des informations exactes
                        
                        NIOS :
                        • Faciliter la mise en relation
                        • Traiter les paiements de manière sécurisée
                        • Fournir un support client
                        """
                    )
                    
                    section(
                        title: "5. Paiements et Facturation",
                        content: """
                        • Les paiements sont traités par Stripe, un processeur de paiement certifié
                        • Les prix sont affichés en euros (EUR) TTC
                        • Les paiements sont pré-autorisés lors de la réservation
                        • Le paiement est capturé lorsque le prestataire confirme la réservation
                        • Les remboursements sont traités selon notre politique de remboursement
                        • NIOS prélève une commission de 10% sur chaque transaction
                        
                        Pour les prestataires :
                        • Les payouts sont effectués via Stripe Connect
                        • Un onboarding Stripe est requis pour recevoir les paiements
                        """
                    )
                    
                    section(
                        title: "6. Annulations et Remboursements",
                        content: """
                        Annulation par le client :
                        • Plus de 24h avant : remboursement complet
                        • Moins de 24h avant : remboursement partiel ou aucun remboursement (selon la politique du prestataire)
                        
                        Annulation par le prestataire :
                        • Remboursement complet au client
                        • Le prestataire peut être pénalisé en cas d'annulations répétées
                        
                        Les remboursements sont traités sous 5-7 jours ouvrés.
                        """
                    )
                    
                    section(
                        title: "7. Sign in with Apple",
                        content: """
                        Si vous utilisez Sign in with Apple :
                        
                        • Vous vous connectez avec votre identifiant Apple
                        • Apple peut masquer votre email (un email relais est utilisé)
                        • Nous respectons les conditions d'utilisation d'Apple
                        • Vous pouvez révoquer l'accès depuis les paramètres Apple
                        
                        Consultez les conditions d'utilisation d'Apple : https://www.apple.com/legal/internet-services/itunes/
                        """
                    )
                    
                    section(
                        title: "8. Propriété Intellectuelle",
                        content: """
                        • Tous les contenus de l'application (logos, textes, images) sont la propriété de NIOS
                        • Vous ne pouvez pas copier, modifier ou distribuer le contenu sans autorisation
                        • Les avis et commentaires que vous publiez deviennent la propriété de NIOS
                        """
                    )
                    
                    section(
                        title: "9. Limitation de Responsabilité",
                        content: """
                        NIOS agit en tant qu'intermédiaire. Nous ne sommes pas responsables :
                        
                        • De la qualité des services fournis par les prestataires
                        • Des dommages causés aux véhicules pendant le service
                        • Des retards ou annulations des prestataires
                        • Des problèmes de paiement liés à Stripe (voir section 10)
                        
                        Les prestataires sont indépendants et responsables de leurs propres services.
                        """
                    )
                    
                    section(
                        title: "10. Stripe - Mentions Légales",
                        content: """
                        Les paiements sont traités par Stripe, Inc. :
                        
                        • Stripe est certifié PCI-DSS niveau 1
                        • Stripe est soumis aux lois américaines et européennes
                        • Pour les prestataires : Stripe Connect est utilisé pour les payouts
                        • Les frais Stripe sont inclus dans nos tarifs
                        
                        En utilisant NIOS, vous acceptez également les conditions d'utilisation de Stripe : https://stripe.com/legal
                        
                        Pour toute question sur les paiements, contactez Stripe directement.
                        """
                    )
                    
                    section(
                        title: "11. Modifications des Conditions",
                        content: """
                        Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications importantes vous seront notifiées via l'application.
                        """
                    )
                    
                    section(
                        title: "12. Résiliation",
                        content: """
                        Nous nous réservons le droit de suspendre ou résilier votre compte en cas de :
                        
                        • Violation de ces conditions
                        • Comportement frauduleux
                        • Utilisation abusive de la plateforme
                        """
                    )
                    
                    section(
                        title: "13. Droit Applicable",
                        content: """
                        Ces conditions sont régies par le droit belge. Tout litige sera soumis aux tribunaux compétents de Belgique.
                        """
                    )
                    
                    section(
                        title: "14. Contact",
                        content: """
                        Pour toute question concernant ces conditions :
                        
                        Email : \(LegalInfo.supportEmail)
                        Adresse : \(LegalInfo.address)
                        """
                    )
                }
                .padding(20)
            }
            .navigationTitle("Conditions d'Utilisation")
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

