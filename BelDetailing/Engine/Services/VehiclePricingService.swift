//
//  VehiclePricingService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

/// Service pour adapter le prix et la durée selon le type de véhicule
protocol VehiclePricingService {
    /// Calcule le prix ajusté selon le type de véhicule
    func calculateAdjustedPrice(basePrice: Double, vehicleType: VehicleType?) -> Double
    
    /// Calcule la durée ajustée selon le type de véhicule
    func calculateAdjustedDuration(baseDurationMinutes: Int, vehicleType: VehicleType?) -> Int
}

final class VehiclePricingServiceImplementation: VehiclePricingService {
    
    /// Multiplicateurs de prix selon le type de véhicule
    private let priceMultipliers: [VehicleType: Double] = [
        .berline: 1.0,        // Prix de base
        .suv: 1.20,           // Plus cher (plus grand)
        .familial: 1.30,      // Plus cher (très grand)
        .utilitaire: 1.25     // Plus cher (grand volume)
    ]
    
    /// Multiplicateurs de durée selon le type de véhicule
    private let durationMultipliers: [VehicleType: Double] = [
        .berline: 1.0,        // Durée de base
        .suv: 1.15,           // Plus long (plus grand)
        .familial: 1.30,      // Plus long (très grand)
        .utilitaire: 1.25     // Plus long (grand volume)
    ]
    
    func calculateAdjustedPrice(basePrice: Double, vehicleType: VehicleType?) -> Double {
        guard let vehicleType = vehicleType,
              let multiplier = priceMultipliers[vehicleType] else {
            // Si pas de type de véhicule, retourner le prix de base
            return basePrice
        }
        
        let adjustedPrice = basePrice * multiplier
        return round(adjustedPrice * 100) / 100 // Arrondir à 2 décimales
    }
    
    func calculateAdjustedDuration(baseDurationMinutes: Int, vehicleType: VehicleType?) -> Int {
        guard let vehicleType = vehicleType,
              let multiplier = durationMultipliers[vehicleType] else {
            // Si pas de type de véhicule, retourner la durée de base
            return baseDurationMinutes
        }
        
        let adjustedDuration = Double(baseDurationMinutes) * multiplier
        return Int(round(adjustedDuration))
    }
}

