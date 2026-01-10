//
//  VehicleType.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case berline      // Berlines classiques (berline, coupe, cabriolet, break)
    case suv          // SUV
    case familial     // Véhicules familiaux (monospace, van)
    case utilitaire   // Utilitaires
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .berline: return "Berline"
        case .suv: return "SUV"
        case .familial: return "Familial"
        case .utilitaire: return "Utilitaire"
        }
    }
    
    var icon: String {
        switch self {
        case .berline: return "car.fill"
        case .suv: return "car.2.fill"
        case .familial: return "car.rear.fill"
        case .utilitaire: return "truck.box.fill"
        }
    }
    
    /// Nom de l'image du véhicule (à ajouter dans Assets)
    var imageName: String {
        switch self {
        case .berline: return "vehicle_berline"
        case .suv: return "vehicle_suv"
        case .familial: return "vehicle_familial"
        case .utilitaire: return "vehicle_utilitaire"
        }
    }
    
    /// Description du véhicule
    var description: String {
        switch self {
        case .berline: return "Voitures de tourisme"
        case .suv: return "Robuste et polyvalent"
        case .familial: return "Spacieux et pratique"
        case .utilitaire: return "Grand volume"
        }
    }
    
    /// Sous-titre avec exemples (comme dans la photo)
    var subtitle: String {
        switch self {
        case .berline: return "Berline, coupé, cabriolet, break"
        case .suv: return "X5, GLE, Cayenne..."
        case .familial: return "Monospace, van"
        case .utilitaire: return "Sprinter, Transit..."
        }
    }
    
    // MARK: - Migration Helper (pour compatibilité avec anciennes valeurs)
    
    /// Convertit les anciennes valeurs vers les nouvelles
    static func fromLegacyValue(_ legacyValue: String) -> VehicleType? {
        switch legacyValue.lowercased() {
        case "berline", "coupe", "cabriolet", "stationwagon", "break":
            return .berline
        case "suv":
            return .suv
        case "monospace", "van":
            return .familial
        case "utilitaire":
            return .utilitaire
        default:
            return nil
        }
    }
    
    /// Convertit vers les anciennes valeurs (pour compatibilité backend si nécessaire)
    var legacyValues: [String] {
        switch self {
        case .berline:
            return ["berline", "coupe", "cabriolet", "stationWagon"]
        case .suv:
            return ["suv"]
        case .familial:
            return ["monospace", "van"]
        case .utilitaire:
            return ["utilitaire"]
        }
    }
}
