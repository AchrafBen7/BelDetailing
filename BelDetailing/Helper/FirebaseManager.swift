//
//  FirebaseManager.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import Foundation
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics

/// Manager pour Firebase (Crashlytics + Analytics)
final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private var isConfigured = false
    
    private init() {}
    
    /// Configure Firebase avec le fichier GoogleService-Info.plist
    func configure() {
        guard !isConfigured else { return }
        
        // Vérifier que GoogleService-Info.plist existe
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            print("⚠️ [Firebase] GoogleService-Info.plist non trouvé. Firebase ne sera pas initialisé.")
            return
        }
        
        // Initialiser Firebase
        FirebaseApp.configure()
        isConfigured = true
        
        print("✅ [Firebase] Firebase configuré avec succès")
        
        // Configurer Crashlytics
        setupCrashlytics()
        
        // Configurer Analytics
        setupAnalytics()
    }
    
    // MARK: - Crashlytics
    
    private func setupCrashlytics() {
        // Activer la collecte de crash reports
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Logger un message pour tester
        Crashlytics.crashlytics().log("Firebase Crashlytics initialisé")
        
        print("✅ [Firebase] Crashlytics configuré")
    }
    
    /// Enregistre un utilisateur pour Crashlytics
    func setUser(userId: String, email: String? = nil) {
        Crashlytics.crashlytics().setUserID(userId)
        if let email = email {
            Crashlytics.crashlytics().setCustomValue(email, forKey: "email")
        }
    }
    
    /// Log un message pour Crashlytics
    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    /// Log une erreur pour Crashlytics
    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        let nsError = error as NSError
        var errorUserInfo = nsError.userInfo
        
        if let userInfo = userInfo {
            errorUserInfo.merge(userInfo) { _, new in new }
        }
        
        let customError = NSError(
            domain: nsError.domain,
            code: nsError.code,
            userInfo: errorUserInfo
        )
        
        Crashlytics.crashlytics().record(error: customError)
    }
    
    // MARK: - Analytics
    
    private func setupAnalytics() {
        // Activer la collecte d'analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        
        print("✅ [Firebase] Analytics configuré")
    }
    
    /// Enregistre un événement analytics
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    /// Enregistre l'ID utilisateur pour Analytics
    func setUserId(_ userId: String?) {
        if let userId = userId, !userId.isEmpty {
            Analytics.setUserID(userId)
        } else {
            Analytics.setUserID(nil) // Réinitialiser l'ID utilisateur
        }
    }
    
    /// Définit une propriété utilisateur
    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    /// Événements prédéfinis pour l'app
    enum Event {
        static let userSignedUp = "user_signed_up"
        static let userLoggedIn = "user_logged_in"
        static let bookingCreated = "booking_created"
        static let bookingConfirmed = "booking_confirmed"
        static let bookingCancelled = "booking_cancelled"
        static let serviceStarted = "service_started"
        static let serviceCompleted = "service_completed"
        static let paymentCompleted = "payment_completed"
        static let paymentFailed = "payment_failed"
        static let reviewSubmitted = "review_submitted"
        static let providerServiceCreated = "provider_service_created"
        static let offerCreated = "offer_created"
        static let applicationSubmitted = "application_submitted"
    }
}

