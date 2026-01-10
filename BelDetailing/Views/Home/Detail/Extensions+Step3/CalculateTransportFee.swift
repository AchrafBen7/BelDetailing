//
//  CalculateTransportFee.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import CoreLocation

extension BookingStep3View {
    
    /// Calcule les frais de transport selon les zones fixes (Option B)
    /// RÈGLE 1.0.1 : Uniquement si hasMobileService = true
    /// RÈGLE 1.0.2 : Zones fixes avec plafond 20€ (pas de limite de distance)
    /// Pas de limite de distance - c'est au detailer de refuser s'il ne veut pas se déplacer
    @MainActor
    func calculateTransportFee() async {
        // Réinitialiser les erreurs
        transportFeeError = nil
        
        // RÈGLE 1.0.1 : Vérifier que le detailer a activé le service à domicile
        guard detailer.hasMobileService else {
            calculatedTransportFee = 0
            calculatedTransportDistanceKm = nil
            transportFeeError = nil // Pas d'erreur, juste pas de service à domicile
            return
        }
        
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            calculatedTransportFee = 0
            calculatedTransportDistanceKm = nil
            return
        }
        
        isCalculatingTransportFee = true
        defer { isCalculatingTransportFee = false }
        
        var transportFee: Double = 0
        var transportDistanceKm: Double? = nil
        
        // Géocoder l'adresse du customer pour obtenir les coordonnées
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location {
                let customerAddressLat = location.coordinate.latitude
                let customerAddressLng = location.coordinate.longitude
                
                // Calculer la distance si le provider a des coordonnées
                if detailer.lat != 0, detailer.lng != 0 {
                    let providerCoord = CLLocationCoordinate2D(latitude: detailer.lat, longitude: detailer.lng)
                    let customerCoord = CLLocationCoordinate2D(latitude: customerAddressLat, longitude: customerAddressLng)
                    
                    // Calculer la distance
                    let distanceService = DistanceServiceImplementation()
                    transportDistanceKm = distanceService.calculateDistance(from: providerCoord, to: customerCoord)
                    
                    guard let distance = transportDistanceKm else {
                        calculatedTransportFee = 0
                        calculatedTransportDistanceKm = nil
                        return
                    }
                    
                    // RÈGLE 1.0.4 : Pas de vérification du rayon max côté client
                    // Le client peut choisir n'importe quelle distance
                    // Les frais sont toujours plafonnés à 20€ max
                    // C'est au detailer de refuser s'il ne veut pas se déplacer
                    
                    // RÈGLE 1.0.2 : Zones fixes avec plafond 20€
                    // 0-10 km : Gratuit
                    // 10-25 km : +15€
                    // >25 km : +20€ (MAX - plafond absolu à 20€)
                    // Pas de limite de distance - c'est au detailer de refuser s'il veut
                    
                    if distance > 25 {
                        transportFee = 20.0 // MAX (plafond absolu à 20€, quelle que soit la distance)
                    } else if distance > 10 {
                        transportFee = 15.0
                    } else {
                        transportFee = 0.0 // Gratuit pour 0-10 km
                    }
                }
            }
        } catch {
            print("⚠️ [BookingStep3View] Geocoding error:", error.localizedDescription)
            // Continuer sans frais de transport si le géocodage échoue
        }
        
        calculatedTransportFee = transportFee
        calculatedTransportDistanceKm = transportDistanceKm
    }
    
    /// Retourne le message à afficher pour les frais de transport
    var transportFeeMessage: String? {
        guard detailer.hasMobileService else {
            return nil // Pas de service à domicile, pas de message
        }
        
        if let error = transportFeeError {
            return error
        }
        
        guard let distance = calculatedTransportDistanceKm else {
            return nil
        }
        
        if distance <= 10 {
            return "Déplacement gratuit"
        } else if distance <= 25 {
            return "Frais de déplacement : +15 €"
        } else {
            return "Frais de déplacement : +20 €" // MAX - plafond à 20€, quelle que soit la distance
        }
    }
}
