//
//  LegalInfo.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

/// Informations légales centralisées pour l'application
/// ⚠️ IMPORTANT : Remplir toutes les informations avant la soumission App Store
struct LegalInfo {
    // MARK: - Éditeur / Entreprise
    
    /// Nom de l'entreprise
    static let companyName: String = "NIOS" // ⚠️ À compléter avec le vrai nom
    
    /// Raison sociale complète
    static let legalName: String = "NIOS" // ⚠️ À compléter avec la raison sociale complète
    
    /// Adresse complète
    static let address: String = "Rue de Lombartzyde 179, 1120 Bruxelles, Belgique" // ⚠️ À compléter avec la vraie adresse
    
    /// Code postal
    static let postalCode: String = "1120" // ⚠️ À compléter
    
    /// Ville
    static let city: String = "Bruxelles" // ⚠️ À compléter
    
    /// Pays
    static let country: String = "Belgique" // ⚠️ À compléter
    
    /// Numéro SIRET / Numéro d'entreprise (si applicable)
    static let companyNumber: String? = nil // ⚠️ À compléter si applicable (ex: "BE 1234.567.890")
    
    /// Numéro de TVA
    static let vatNumber: String? = nil // ⚠️ À compléter si applicable
    
    // MARK: - Contact
    
    /// Email de support
    static let supportEmail: String = "support@nios.app" // ⚠️ À compléter avec le vrai email
    
    /// Téléphone de support
    static let supportPhone: String? = nil // ⚠️ À compléter avec le vrai numéro (ex: "+32 2 123 45 67")
    
    /// URL du site web (si applicable)
    static let websiteURL: String? = nil // ⚠️ À compléter si applicable (ex: "https://nios.app")
    
    // MARK: - Directeur de Publication
    
    /// Nom du directeur de publication
    static let directorName: String? = nil // ⚠️ À compléter
    
    // MARK: - Hébergeur
    
    /// Nom de l'hébergeur
    static let hostName: String = "Supabase" // ⚠️ À compléter avec le vrai hébergeur
    
    /// Adresse de l'hébergeur
    static let hostAddress: String = "Supabase Inc., 970 Toa Payoh North, #07-04, Singapore 318992" // ⚠️ À compléter
    
    /// Téléphone de l'hébergeur
    static let hostPhone: String? = nil // ⚠️ À compléter
    
    // MARK: - Protection des Données
    
    /// Email du Délégué à la Protection des Données (DPO)
    static let dpoEmail: String? = nil // ⚠️ À compléter si applicable (ex: "dpo@nios.app")
    
    // MARK: - URLs App Store
    
    /// URL de la Privacy Policy (pour App Store Connect)
    static let privacyPolicyURL: String? = nil // ⚠️ À compléter si hébergée en ligne (ex: "https://nios.app/privacy")
    
    /// URL des Terms of Service (pour App Store Connect)
    static let termsOfServiceURL: String? = nil // ⚠️ À compléter si hébergés en ligne (ex: "https://nios.app/terms")
    
    /// URL du support (pour App Store Connect)
    static let supportURL: String? = nil // ⚠️ À compléter (ex: "https://nios.app/support" ou email)
}

