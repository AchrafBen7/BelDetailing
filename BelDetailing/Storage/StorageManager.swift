//
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
        defaults.set(value, forKey: key.rawValue)
    }

    private func getString(forKey key: UserDefaultsKeys) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    private func remove(_ key: UserDefaultsKeys) {
        defaults.removeObject(forKey: key.rawValue)
    }

    // MARK: - Public Shortcuts

    // 👤 User
    func saveUser(_ user: User?) { save(user, forKey: .userProfile) }
    func getUser() -> User? { get(User.self, forKey: .userProfile) }

    func saveAuthToken(_ token: String?) { saveString(token, forKey: .authToken) }
    func getAuthToken() -> String? { getString(forKey: .authToken) }

    func saveUserRole(_ role: UserRole?) { saveString(role?.rawValue, forKey: .userRole) }
    func getUserRole() -> UserRole? {
        guard let raw = getString(forKey: .userRole) else { return nil }
        return UserRole(rawValue: raw)
    }

    // 🏙 City
    func saveSelectedCity(_ city: City?) { save(city, forKey: .selectedCity) }
    func getSelectedCity() -> City? { get(City.self, forKey: .selectedCity) }

    // 💼 Cached Data
    func saveCachedOffers(_ offers: [Offer]) { save(offers, forKey: .cachedOffers) }
    func getCachedOffers() -> [Offer] { get([Offer].self, forKey: .cachedOffers) ?? [] }

    func saveCachedProviders(_ providers: [Detailer]) { save(providers, forKey: .cachedProviders) }
    func getCachedProviders() -> [Detailer] { get([Detailer].self, forKey: .cachedProviders) ?? [] }

    func saveCachedBookings(_ bookings: [Booking]) { save(bookings, forKey: .cachedBookings) }
    func getCachedBookings() -> [Booking] { get([Booking].self, forKey: .cachedBookings) ?? [] }

    // 🔓 Logout / Reset
    func clearSession() {
        remove(.userProfile)
        remove(.authToken)
        remove(.userRole)
    }
}
