//
//  PrivacyPolicyView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Politique de Confidentialité")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 8)
                    
                    Text("Dernière mise à jour : 1er janvier 2026")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Sections
                    section(
                        title: "1. Introduction",
                        content: """
                        NIOS ("nous", "notre", "l'application") s'engage à protéger votre vie privée. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations personnelles lorsque vous utilisez notre application mobile.
                        """
                    )
                    
                    section(
                        title: "2. Données Collectées",
                        content: """
                        Nous collectons les informations suivantes :
                        
                        • Informations de compte : nom, email, numéro de téléphone
                        • Informations de profil : adresse, préférences de service
                        • Informations de paiement : gérées par Stripe (voir section 5)
                        • Données d'utilisation : réservations, transactions, interactions
                        • Données de localisation : pour trouver des prestataires à proximité
                        • Données techniques : identifiant d'appareil, type d'appareil, système d'exploitation
                        """
                    )
                    
                    section(
                        title: "3. Utilisation des Données",
                        content: """
                        Nous utilisons vos données pour :
                        
                        • Fournir et améliorer nos services
                        • Traiter vos réservations et paiements
                        • Vous connecter avec des prestataires
                        • Vous envoyer des notifications importantes
                        • Personnaliser votre expérience
                        • Respecter nos obligations légales
                        """
                    )
                    
                    section(
                        title: "4. Partage des Données",
                        content: """
                        Nous partageons vos données uniquement avec :
                        
                        • Prestataires de services : pour traiter vos réservations
                        • Stripe : pour le traitement des paiements (voir section 5)
                        • Google : pour Sign in with Google (si utilisé)
                        • Apple : pour Sign in with Apple (si utilisé)
                        • Prestataires techniques : hébergement, analytics (voir section 6)
                        
                        Nous ne vendons jamais vos données à des tiers.
                        """
                    )
                    
                    section(
                        title: "5. Paiements Stripe",
                        content: """
                        Les paiements sont traités par Stripe, un processeur de paiement certifié PCI-DSS. Lorsque vous effectuez un paiement :
                        
                        • Vos informations de carte sont transmises directement à Stripe
                        • Nous ne stockons jamais vos numéros de carte complets
                        • Stripe collecte et traite vos données selon sa propre politique de confidentialité
                        • Pour les prestataires : Stripe Connect est utilisé pour les payouts
                        
                        Consultez la politique de confidentialité de Stripe : https://stripe.com/privacy
                        """
                    )
                    
                    section(
                        title: "6. Analytics et Monitoring",
                        content: """
                        Nous utilisons des services d'analytics pour améliorer notre application :
                        
                        • Firebase Analytics : pour comprendre l'utilisation de l'app
                        • Firebase Crashlytics : pour identifier et corriger les bugs
                        
                        Ces services peuvent collecter des données anonymisées sur votre utilisation.
                        """
                    )
                    
                    section(
                        title: "7. Vos Droits (RGPD)",
                        content: """
                        Conformément au RGPD, vous avez le droit de :
                        
                        • Accéder à vos données personnelles
                        • Rectifier vos données inexactes
                        • Supprimer vos données ("droit à l'oubli")
                        • Limiter le traitement de vos données
                        • Vous opposer au traitement
                        • Portabilité de vos données
                        
                        Pour exercer ces droits, contactez-nous à : support@nios.app
                        """
                    )
                    
                    section(
                        title: "8. Conservation des Données",
                        content: """
                        Nous conservons vos données :
                        
                        • Pendant la durée de votre compte
                        • Pendant 3 ans après la fermeture de votre compte (obligations légales)
                        • Les données de transaction sont conservées 10 ans (obligations fiscales)
                        """
                    )
                    
                    section(
                        title: "9. Sécurité",
                        content: """
                        Nous mettons en œuvre des mesures de sécurité appropriées :
                        
                        • Chiffrement des données en transit (HTTPS)
                        • Authentification sécurisée (JWT)
                        • Stockage sécurisé des données
                        • Accès restreint aux données personnelles
                        """
                    )
                    
                    section(
                        title: "10. Cookies et Technologies Similaires",
                        content: """
                        Notre application mobile n'utilise pas de cookies web traditionnels. Nous utilisons :
                        
                        • Identifiants d'appareil pour l'authentification
                        • Tokens de session pour maintenir votre connexion
                        • Local storage pour préférences utilisateur
                        """
                    )
                    
                    section(
                        title: "11. Modifications",
                        content: """
                        Nous pouvons modifier cette politique de confidentialité. Les modifications importantes vous seront notifiées via l'application ou par email.
                        """
                    )
                    
                    section(
                        title: "12. Contact",
                        content: """
                        Pour toute question concernant cette politique de confidentialité :
                        
                        Email : \(LegalInfo.supportEmail)
                        Adresse : \(LegalInfo.address)
                        """
                    )
                }
                .padding(20)
            }
            .navigationTitle("Politique de Confidentialité")
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

