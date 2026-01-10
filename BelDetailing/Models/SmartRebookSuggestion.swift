//
//  SmartRebookSuggestion.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import Foundation

/// Suggestion de ré-booking automatique après un service complété
struct SmartRebookSuggestion: Codable, Identifiable {
    let id: String
    let originalBookingId: String
    let providerId: String
    let providerName: String
    let serviceIds: [String]
    let serviceNames: [String]
    let suggestedDate: String // ISO 8601
    let suggestedStartTime: String // HH:mm
    let suggestedEndTime: String // HH:mm
    let address: String
    let totalPrice: Double
    let currency: String
    let message: String? // Message personnalisé optionnel
    
    /// Calculer la date suggérée (6 semaines après la date du service original)
    static func calculateSuggestedDate(from originalDate: String, originalStartTime: String) -> (date: String, startTime: String, endTime: String) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        
        // Parser la date originale
        guard let originalDateTime = dateFormatter.date(from: "\(originalDate)T\(originalStartTime):00") else {
            // Fallback : utiliser la date actuelle + 6 semaines
            let futureDate = Calendar.current.date(byAdding: .weekOfYear, value: 6, to: Date()) ?? Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd"
            let dateStr = timeFormatter.string(from: futureDate)
            return (date: dateStr, startTime: originalStartTime, endTime: originalStartTime)
        }
        
        // Ajouter 6 semaines
        guard let suggestedDateTime = Calendar.current.date(byAdding: .weekOfYear, value: 6, to: originalDateTime) else {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd"
            let dateStr = timeFormatter.string(from: originalDateTime)
            return (date: dateStr, startTime: originalStartTime, endTime: originalStartTime)
        }
        
        // Formatter la date suggérée
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter2.string(from: suggestedDateTime)
        
        // Extraire l'heure de la date originale
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTimeStr = timeFormatter.string(from: originalDateTime)
        
        // Calculer l'heure de fin (même durée)
        let endTimeStr = startTimeStr // Simplifié, on garde la même heure
        
        return (date: dateStr, startTime: startTimeStr, endTime: endTimeStr)
    }
}

