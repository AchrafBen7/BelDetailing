//
//  MockService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//


import Foundation

/// Classe de base utilisée pour tous les services mockés (CityServiceMock, BookingServiceMock, etc.)
/// Elle permet de simuler un comportement réseau réaliste sans dépendre du backend.
class MockService {
    
    // MARK: - Simule un délai réseau aléatoire
    func randomWait(min: Double = 0.2, max: Double = 1.2) async {
        let delay = UInt64(Double.random(in: min...max) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }
    
    // MARK: - Charge un fichier JSON mock depuis les ressources locales
    /// Exemple : `loadMockJSON("bookings.json", type: [Booking].self)`
    func loadMockJSON<T: Decodable>(_ filename: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("❌ [MockService] Fichier \(filename) introuvable dans le bundle.")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = NetworkClient.defaultDecoder
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[MockService] Erreur de décodage du fichier \(filename): \(error)")
            return nil
        }
    }
    
    // MARK: - Simule une réponse de succès ou d'erreur
    func simulate<T>(_ data: T?, errorRate: Double = 0.05) -> APIResponse<T> {
        // Simule un petit taux d’erreurs réseau (~5%)
        if Double.random(in: 0...1) < errorRate {
            return .failure(.serverError(statusCode: Int.random(in: 400...500)))
        }
        if let data = data {
            return .success(data)
        } else {
            return .failure(.unknownError)
        }
    }
    
    // MARK: - Exemple de succès générique (pour tests)
    func success<T>(_ value: T) -> APIResponse<T> { .success(value) }
    
    // MARK: - Exemple d'erreur générique
    func failure<T>(_ message: String? = nil) -> APIResponse<T> {
        .failure(.other(error: NSError(domain: "MockService", code: -1, userInfo: [
            NSLocalizedDescriptionKey: message ?? "Mock error"
        ])))
    }
}
