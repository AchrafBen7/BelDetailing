//
//  ServiceCategory.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation
import RswiftResources

/// Catégories statiques de base (fallback + clé backend)
enum ServiceCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case carCleaning = "car_cleaning"
    case carPolishing = "car_polishing"
    case interiorDetailing = "interior_detailing"
    case ceramicCoating = "ceramic_coating"
    case fleetMaintenance = "fleet_maintenance"
    
    /// Nom localisé (via Localizable.xcstrings + R.swift)
    var displayName: String {
            switch self {
            case .carCleaning:
                return R.string.localizable.serviceCategoryCarCleaning()
            case .carPolishing:
                return R.string.localizable.serviceCategoryCarPolishing()
            case .interiorDetailing:
                return R.string.localizable.serviceCategoryInteriorDetailing()
            case .ceramicCoating:
                return R.string.localizable.serviceCategoryCeramicCoating()
            case .fleetMaintenance:
                return R.string.localizable.serviceCategoryFleetMaintenance()
            }
    }
}
