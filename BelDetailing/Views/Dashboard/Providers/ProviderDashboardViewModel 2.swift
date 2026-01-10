//
//  ProviderDashboardViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import Combine

enum ToastKind {
    case error
    case success
    case info
}

struct ToastState: Equatable {
    let message: String
    let kind: ToastKind
}

@MainActor
final class ProviderDashboardViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedFilter: ProviderDashboardFilter = .offers {
        didSet {
            // Quand on passe à l’onglet Reviews, charger si nécessaire
            if selectedFilter == .reviews, myReviews.isEmpty, !isLoadingReviews {
                Task { await loadMyReviews() }
            }
        }
    }

    @Published var services: [Service] = []
    @Published var isLoading = true

    @Published var bookings: [Booking] = []
    @Published var stats: DetailerStats? = nil

    // Reviews (nouveau)
    @Published var myReviews: [Review] = []
    @Published var isLoadingReviews: Bool = false

    // Ancienne alerte → remplacée par un toast
    @Published var bookingActionError: String? = nil // gardé pour compat, mais non utilisé par l’UI
    @Published var toast: ToastState? = nil          // 👈 état du toast

    // Expose popular services for StatsPlaceholder
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
        // On ne charge pas les reviews ici pour éviter du réseau inutile
        // Elles seront chargées à l'ouverture de l'onglet .reviews via didSet de selectedFilter
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
            let response = await engine.bookingService.getBookings(scope: "provider", status: nil)
            switch response {
            case .success(let list):
                bookings = list
            case .failure:
                bookings = []
            }
        }
    }

    // MARK: - Reviews
    func loadMyReviews() async {
        isLoadingReviews = true
        defer { isLoadingReviews = false }

        let response = await engine.reviewService.getMyReviews()
        switch response {
        case .success(let items):
            myReviews = items
        case .failure:
            myReviews = []
        }
    }

    func deleteService(id: String) {
        services.removeAll { $0.id == id }
    }

    func confirmBooking(_ id: String) {
        Task {
            let res = await engine.bookingService.confirmBooking(id: id)
            switch res {
            case .success:
                bookingActionError = nil
                showToast(message: "Réservation confirmée ✅", kind: .success)
                loadBookings()
            case .failure(let err):
                let rawMessage: String
                if let localized = (err as NSError).userInfo[NSLocalizedDescriptionKey] as? String {
                    rawMessage = localized
                } else {
                    rawMessage = err.localizedDescription
                }

                if rawMessage.localizedCaseInsensitiveContains("Confirmation window expired") ||
                   rawMessage.localizedCaseInsensitiveContains("24h") {
                    showToast(
                        message: "Trop tard. Vous ne pouvez plus accepter une réservation dans les 24h précédant l'heure prévue.",
                        kind: .error
                    )
                } else {
                    showToast(message: rawMessage, kind: .error)
                }
            }
        }
    }

    func declineBooking(_ id: String) {
        Task {
            let res = await engine.bookingService.declineBooking(id: id)
            switch res {
            case .success:
                bookingActionError = nil
                showToast(message: "Réservation refusée.", kind: .info)
                loadBookings()
            case .failure(let err):
                showToast(message: err.localizedDescription, kind: .error)
            }
        }
    }

    // MARK: - Toast helper
    private func showToast(message: String, kind: ToastKind) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            toast = ToastState(message: message, kind: kind)
        }
        // Auto-hide after 3s
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeOut(duration: 0.25)) {
                if toast?.message == message { toast = nil }
            }
        }
    }
}

enum ProviderDashboardFilter {
    case offers, calendar, stats, reviews, stripe
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
            case .started, .inProgress:
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

