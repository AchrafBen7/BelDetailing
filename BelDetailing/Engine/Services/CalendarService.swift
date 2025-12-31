//
//  CalendarService.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import EventKit
import Combine
import UIKit

// MARK: - Protocol
protocol CalendarService {
    func requestAuthorization() async -> Bool
    func syncBooking(_ booking: Booking) async -> Result<String, Error>
    func removeBooking(_ bookingId: String) async -> Result<Bool, Error>
    func syncAllBookings(_ bookings: [Booking]) async -> Result<Int, Error>
    func getAuthorizationStatus() -> EKAuthorizationStatus
}

// MARK: - EventKit Implementation
@MainActor
final class CalendarServiceEventKit: CalendarService {
    private let eventStore = EKEventStore()
    private let calendarTitle = "NIOS Reservations"
    private var calendar: EKCalendar?
    
    // MARK: - Authorization
    
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAuthorization() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            await ensureCalendarExists()
            return true
        case .notDetermined:
            do {
                let granted = try await eventStore.requestAccess(to: .event)
                if granted {
                    await ensureCalendarExists()
                    return true
                }
                return false
            } catch {
                return false
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Calendar Management
    
    private func ensureCalendarExists() async {
        // Chercher le calendrier NIOS
        let calendars = eventStore.calendars(for: .event)
        calendar = calendars.first { $0.title == calendarTitle }
        
        // Si pas trouvé, créer un nouveau calendrier
        if calendar == nil {
            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
            newCalendar.title = calendarTitle
            newCalendar.cgColor = UIColor.systemBlue.cgColor
            
            // Utiliser la source par défaut de l'utilisateur
            if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
                newCalendar.source = defaultCalendar.source
            } else if let iCloudSource = eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title.contains("iCloud") }) {
                newCalendar.source = iCloudSource
            } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
                newCalendar.source = localSource
            }
            
            do {
                try eventStore.saveCalendar(newCalendar, commit: true)
                calendar = newCalendar
            } catch {
                print("❌ [CalendarService] Failed to create calendar: \(error)")
            }
        }
    }
    
    // MARK: - Sync Booking
    
    func syncBooking(_ booking: Booking) async -> Result<String, Error> {
        guard let calendar = await getCalendar() else {
            return .failure(CalendarError.calendarNotFound)
        }
        
        // Vérifier si l'événement existe déjà
        let existingEventId = await findEventId(for: booking.id)
        
        do {
            let event: EKEvent
            if let eventId = existingEventId,
               let existingEvent = eventStore.event(withIdentifier: eventId) {
                event = existingEvent
            } else {
                event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
            }
            
            // Mettre à jour les détails de l'événement
            event.title = bookingTitle(for: booking)
            event.notes = bookingNotes(for: booking)
            event.location = booking.address
            
            // Date et heure
            if let startDate = bookingStartDate(booking),
               let endDate = bookingEndDate(booking) {
                event.startDate = startDate
                event.endDate = endDate
                event.isAllDay = false
            } else {
                return .failure(CalendarError.invalidDate)
            }
            
            // Alerte 1 heure avant
            if event.alarms?.isEmpty ?? true {
                event.addAlarm(EKAlarm(relativeOffset: -3600)) // -1 hour
            }
            
            // Note: EKEvent.status est read-only; on ne peut pas le setter.
            // On laisse EventKit dériver le statut à partir du calendrier/organisateur.
            
            try eventStore.save(event, span: .thisEvent, commit: true)
            return .success(event.eventIdentifier)
            
        } catch {
            return .failure(error)
        }
    }
    
    func removeBooking(_ bookingId: String) async -> Result<Bool, Error> {
        guard let eventId = await findEventId(for: bookingId),
              let event = eventStore.event(withIdentifier: eventId) else {
            return .success(false) // Pas d'événement à supprimer
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    func syncAllBookings(_ bookings: [Booking]) async -> Result<Int, Error> {
        guard await getCalendar() != nil else {
            return .failure(CalendarError.calendarNotFound)
        }
        
        var syncedCount = 0
        var lastError: Error?
        
        for booking in bookings {
            // Ne synchroniser que les bookings confirmés, en cours ou à venir
            guard booking.status == .confirmed ||
                  booking.status == .started ||
                  booking.status == .inProgress ||
                  booking.status == .pending else {
                continue
            }
            
            let result = await syncBooking(booking)
            switch result {
            case .success:
                syncedCount += 1
            case .failure(let error):
                lastError = error
            }
        }
        
        if syncedCount > 0 {
            return .success(syncedCount)
        } else if let error = lastError {
            return .failure(error)
        } else {
            return .success(0)
        }
    }
    
    // MARK: - Helpers
    
    private func getCalendar() async -> EKCalendar? {
        if calendar == nil {
            await ensureCalendarExists()
        }
        return calendar
    }
    
    private func findEventId(for bookingId: String) async -> String? {
        guard let calendar = await getCalendar() else { return nil }
        
        // Chercher dans les événements des 6 prochains mois
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 6, to: startDate) ?? startDate
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: [calendar]
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Chercher l'événement avec le bookingId dans les notes
        return events.first { event in
            event.notes?.contains("NIOS_BOOKING_ID:\(bookingId)") == true
        }?.eventIdentifier
    }
    
    private func bookingTitle(for booking: Booking) -> String {
        let serviceName = booking.serviceName ?? "Service"
        let customerName = booking.customer?.firstName ?? "Client"
        return "\(serviceName) - \(customerName)"
    }
    
    private func bookingNotes(for booking: Booking) -> String {
        var notes = "NIOS_BOOKING_ID:\(booking.id)\n\n"
        notes += "Service: \(booking.serviceName ?? "N/A")\n"
        if let customer = booking.customer {
            notes += "Client: \(customer.firstName) \(customer.lastName)\n"
            notes += "Email: \(customer.email)\n"
            notes += "Téléphone: \(customer.phone)\n"
        }
        notes += "Prix: €\(String(format: "%.2f", booking.price))\n"
        notes += "Adresse: \(booking.address)\n"
        return notes
    }
    
    private func bookingStartDate(_ booking: Booking) -> Date? {
        guard let date = DateFormatters.isoDate(booking.date),
              let time = booking.startTime else {
            return nil
        }
        
        let timeComponents = time.split(separator: ":")
        guard timeComponents.count == 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            return nil
        }
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
    
    private func bookingEndDate(_ booking: Booking) -> Date? {
        guard let startDate = bookingStartDate(booking) else {
            return nil
        }
        
        // Par défaut, ajouter 2 heures (durée estimée d'un service)
        return Calendar.current.date(byAdding: .hour, value: 2, to: startDate)
    }
}

// MARK: - Errors
enum CalendarError: LocalizedError {
    case calendarNotFound
    case invalidDate
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .calendarNotFound:
            return "Calendar not found"
        case .invalidDate:
            return "Invalid booking date"
        case .authorizationDenied:
            return "Calendar access denied"
        }
    }
}
