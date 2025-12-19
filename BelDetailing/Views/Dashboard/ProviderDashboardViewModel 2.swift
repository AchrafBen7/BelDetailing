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
    @Published var selectedDate: Date = Date()
    @Published var selectedFilter: ProviderDashboardFilter = .offers
    @Published var services: [Service] = []
    @Published var isLoading = true
    @Published var bookings: [Booking] = []
    @Published var stats: DetailerStats? = nil

    // Expose popular services for StatsPlaceholder
    // Pour l’instant, DetailerStats ne contient pas ces données,
    // on renvoie donc un tableau vide. À mapper quand l’API les expose.
    var popularServices: [PopularServiceUI] {
        return []
    }

    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
        loadAll()
    }

    func loadAll() {
        loadServices()
        loadBookings()
        loadStats()
    }

    func loadStats() {
        Task {
            let response = await engine.detailerService.getMyStats()
            switch response {
            case .success(let succ):
                self.stats = succ
            case .failure:
                self.stats = nil
            }
        }
    }

    var bookingsForSelectedDate: [Booking] {
        bookings
            .filter { $0.date == selectedDateString }
            .filter { booking in
                booking.status == .confirmed ||
                booking.status == .pending   ||
                booking.status == .cancelled
            }
            .sorted { ($0.startTime ?? "00:00") < ($1.startTime ?? "00:00") }
    }

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
        DateFormatters.onlyDate(selectedDate)
    }

    func loadServices() {
        Task {
            isLoading = true
            let response = await engine.detailerService.getMyServices()
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
            // Backend reads provider from JWT; scope must be "provider"
            let response = await engine.bookingService.getBookings(scope: "provider", status: nil)
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

    func confirmBooking(_ id: String) {
        Task {
            let res = await engine.bookingService.confirmBooking(id: id)
            if case .success = res {
                loadBookings()
            }
        }
    }

    func declineBooking(_ id: String) {
        Task {
            let res = await engine.bookingService.declineBooking(id: id)
            if case .success = res {
                loadBookings()
            }
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
            case .declined, .cancelled, .completed:
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

