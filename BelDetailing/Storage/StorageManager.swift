//  StorageManager.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

/// Gestion centralisée des données locales (UserDefaults)
final class StorageManager {
    static let shared = StorageManager()
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Generic Encode / Decode
    private func save<T: Codable>(_ value: T?, forKey key: UserDefaultsKeys) {
        guard let value else {
            defaults.removeObject(forKey: key.rawValue)
            return
        }
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }

    private func get<T: Codable>(_ type: T.Type, forKey key: UserDefaultsKeys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveString(_ value: String?, forKey key: UserDefaultsKeys) {
        if let value {
            defaults.set(value, forKey: key.rawValue)
        } else {
            defaults.removeObject(forKey: key.rawValue)
        }
    }

    private func getString(forKey key: UserDefaultsKeys) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    private func remove(_ key: UserDefaultsKeys) {
        defaults.removeObject(forKey: key.rawValue)
    }

    // MARK: - USER

    func saveUser(_ user: User?) {
        save(user, forKey: .userProfile)
        
        // Configurer Firebase avec les infos utilisateur
        if let user = user {
            FirebaseManager.shared.setUser(userId: user.id, email: user.email)
            FirebaseManager.shared.setUserId(user.id)
            FirebaseManager.shared.setUserProperty(value: user.role.rawValue, forName: "user_role")
        } else {
            // Déconnexion : réinitialiser Firebase
            FirebaseManager.shared.setUser(userId: "", email: nil)
            FirebaseManager.shared.setUserId(nil)
        }
    }
    func getUser() -> User? { get(User.self, forKey: .userProfile) }

    func saveUserRole(_ role: UserRole?) { saveString(role?.rawValue, forKey: .userRole) }
    func getUserRole() -> UserRole? {
        guard let raw = getString(forKey: .userRole) else { return nil }
        return UserRole(rawValue: raw)
    }

    // MARK: - AUTH TOKENS

    func saveAccessToken(_ token: String?) {
        saveString(token, forKey: .accessToken)
    }

    func getAccessToken() -> String? {
        getString(forKey: .accessToken)
    }

    func saveRefreshToken(_ token: String?) {
        saveString(token, forKey: .refreshToken)
    }

    func getRefreshToken() -> String? {
        getString(forKey: .refreshToken)
    }
    // MARK: - CACHED PROVIDERS

    func saveCachedProviders(_ providers: [Detailer]) {
        save(providers, forKey: .cachedProviders)
    }

    func getCachedProviders() -> [Detailer] {
        get([Detailer].self, forKey: .cachedProviders) ?? []
    }

    // MARK: - CACHED BOOKINGS

    func saveCachedBookings(_ bookings: [Booking]) {
        save(bookings, forKey: .cachedBookings)
    }

    func getCachedBookings() -> [Booking] {
        get([Booking].self, forKey: .cachedBookings) ?? []
    }

    // MARK: - LOGIN STATE

    func setLoggedIn(_ value: Bool) {
        defaults.set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }

    func isLoggedIn() -> Bool {
        defaults.bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    // MARK: - CACHED OFFERS

    func saveCachedOffers(_ offers: [Offer]) {
        save(offers, forKey: .cachedOffers)
    }

    func getCachedOffers() -> [Offer] {
        get([Offer].self, forKey: .cachedOffers) ?? []
    }


    // MARK: - LOGOUT

    func clearSession() {
        remove(.userProfile)
        remove(.accessToken)
        remove(.refreshToken)
        remove(.userRole)
        remove(.isLoggedIn)
    }
}
