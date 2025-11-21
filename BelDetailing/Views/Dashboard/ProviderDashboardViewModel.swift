//
//  ProviderDashboardViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import Combine

@MainActor
final class ProviderDashboardViewModel: ObservableObject {
    @Published var selectedFilter: ProviderDashboardFilter = .offers
    @Published var services: [Service] = []
    @Published var isLoading = true
    @Published var bookings: [Booking] = []
    @Published var selectedDate: Date = Date()
    let engine: Engine
    let providerId = "prov_001"  // plus tard depuis StorageManager
    init(engine: Engine) {
        self.engine = engine
        loadServices()
        loadBookings()         // 👈 important pour le calendrier
    }
    // MARK: - Calendar DATA
    /// Réservations pour la date sélectionnée
    var bookingsForSelectedDate: [Booking] {
        bookings
            .filter { $0.date == selectedDateString }
            .filter { booking in
                booking.status == .confirmed ||
                booking.status == .pending   ||
                booking.status == .cancelled
            }
            .sorted { $0.startTime < $1.startTime }   // optionnel mais plus clean
    }
    /// Jours (1,2,3,...) qui ont au moins une réservation pour le mois de `selectedDate`
    func bookedDays(inMonth month: Date) -> Set<Int> {
        var result = Set<Int>()
        let calendar = Calendar.current
        let target = calendar.dateComponents([.year, .month], from: month)
        for booking in bookings {
            guard let date = DateFormatters.isoDate(booking.date) else { continue }
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            guard comps.year == target.year,
                  comps.month == target.month,
                  let day = comps.day
            else { continue }
            result.insert(day)
        }
        return result
    }
    private var selectedDateString: String {
        DateFormatters.onlyDate(selectedDate)   // "yyyy-MM-dd"
    }
    // MARK: - Services & Bookings loader
    func loadServices() {
        Task {
            isLoading = true
            let response = await engine.detailerService.getServices(id: providerId)
            switch response {
            case .success(let list):
                services = list
            case .failure:
                services = []
            }
            isLoading = false
        }
    }
    func loadBookings() {
        Task {
            let response = await engine.bookingService.getBookings(scope: providerId, status: nil)
            switch response {
            case .success(let list):
                bookings = list
            case .failure:
                bookings = []
            }
        }
    }
    func deleteService(id: String) {
        services.removeAll { $0.id == id }
    }
    // MARK: - ACTIONS booking
    func confirmBooking(_ id: String) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].status = .confirmed
        }
    }
    func declineBooking(_ id: String) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].status = .declined
        }
    }
}

enum ProviderDashboardFilter {
    case offers, calendar, stats, reviews
}

struct CalendarDayStatus {
    let confirmed: Set<Int>
    let pending: Set<Int>
    let cancelled: Set<Int>
}

extension ProviderDashboardViewModel {
    
    func calendarStatus(forMonth month: Date) -> CalendarDayStatus {
        
        let calendar = Calendar.current
        let target = calendar.dateComponents([.year, .month], from: month)
        
        var confirmed = Set<Int>()
        var pending   = Set<Int>()
        var cancelled = Set<Int>()
        
        for booking in bookings {
            guard let date = DateFormatters.isoDate(booking.date) else { continue }
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            
            guard comps.year == target.year,
                  comps.month == target.month,
                  let day = comps.day else { continue }
            
            switch booking.status {
            case .confirmed:
                confirmed.insert(day)
                
            case .pending:
                pending.insert(day)
                
            case .declined, .cancelled, .completed:    // tu l'as demandé
                cancelled.insert(day)
            }
        }
        return CalendarDayStatus(
            confirmed: confirmed,
            pending: pending,
            cancelled: cancelled
        )
    }
}
