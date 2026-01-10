//
//  VehicleProfile.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import Foundation

/// Profil d'un véhicule avec historique et préférences
struct VehicleProfile: Codable, Identifiable {
    let id: String
    let vehicleType: VehicleType
    let customerId: String
    
    // Informations du véhicule
    let make: String? // Marque (ex: "BMW")
    let model: String? // Modèle (ex: "X5")
    let year: Int? // Année
    let color: String? // Couleur
    let licensePlate: String? // Plaque d'immatriculation
    
    // Historique
    let pastServices: [VehicleServiceHistory]
    let totalServicesCount: Int
    let totalSpent: Double
    let firstServiceDate: String?
    let lastServiceDate: String?
    
    // Préférences
    let preferredServices: [String] // IDs des services préférés
    let preferredProviders: [String] // IDs des providers préférés
    let notes: String? // Notes du provider sur ce véhicule
    let specialInstructions: String? // Instructions spéciales (ex: "Attention aux jantes")
    
    // Statistiques
    let averageServicePrice: Double
    let mostUsedService: String? // Nom du service le plus utilisé
    let favoriteProvider: String? // Nom du provider préféré
}

/// Historique d'un service pour un véhicule
struct VehicleServiceHistory: Codable, Identifiable {
    let id: String // Booking ID
    let bookingId: String
    let serviceName: String
    let providerName: String
    let date: String
    let price: Double
    let status: BookingStatus
    let rating: Int? // Note donnée (1-5)
    let review: String? // Commentaire laissé
}

// MARK: - Extensions

extension VehicleProfile {
    /// Créer un VehicleProfile depuis un CustomerProfile et une liste de bookings
    static func from(
        customerId: String,
        vehicleType: VehicleType,
        bookings: [Booking],
        make: String? = nil,
        model: String? = nil,
        year: Int? = nil,
        color: String? = nil,
        licensePlate: String? = nil
    ) -> VehicleProfile {
        // Filtrer les bookings complétés
        let completedBookings = bookings.filter { $0.status == .completed }
        
        // Créer l'historique
        let pastServices = completedBookings.map { booking in
            VehicleServiceHistory(
                id: booking.id,
                bookingId: booking.id,
                serviceName: booking.displayServiceName,
                providerName: booking.providerName ?? "Provider",
                date: booking.date,
                price: booking.price,
                status: booking.status,
                rating: nil, // TODO: Récupérer depuis les reviews
                review: nil // TODO: Récupérer depuis les reviews
            )
        }
        
        // Calculer les statistiques
        let totalSpent = pastServices.reduce(0.0) { $0 + $1.price }
        let averageServicePrice = pastServices.isEmpty ? 0.0 : totalSpent / Double(pastServices.count)
        
        // Trouver le service le plus utilisé
        let serviceCounts = Dictionary(grouping: pastServices, by: { $0.serviceName })
            .mapValues { $0.count }
        let mostUsedService = serviceCounts.max(by: { $0.value < $1.value })?.key
        
        // Trouver le provider préféré
        let providerCounts = Dictionary(grouping: pastServices, by: { $0.providerName })
            .mapValues { $0.count }
        let favoriteProvider = providerCounts.max(by: { $0.value < $1.value })?.key
        
        // Dates
        let sortedByDate = pastServices.sorted { $0.date > $1.date }
        let firstServiceDate = sortedByDate.last?.date
        let lastServiceDate = sortedByDate.first?.date
        
        return VehicleProfile(
            id: customerId, // Utiliser customerId comme ID unique
            vehicleType: vehicleType,
            customerId: customerId,
            make: make,
            model: model,
            year: year,
            color: color,
            licensePlate: licensePlate,
            pastServices: pastServices,
            totalServicesCount: pastServices.count,
            totalSpent: totalSpent,
            firstServiceDate: firstServiceDate,
            lastServiceDate: lastServiceDate,
            preferredServices: [], // TODO: Calculer depuis l'historique
            preferredProviders: [], // TODO: Calculer depuis l'historique
            notes: nil,
            specialInstructions: nil,
            averageServicePrice: averageServicePrice,
            mostUsedService: mostUsedService,
            favoriteProvider: favoriteProvider
        )
    }
}

