//  BookingsViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class BookingsViewModel: ObservableObject {

    // MARK: - Published Data
    @Published var allBookings: [Booking] = []
    @Published var upcoming: [Booking] = []
    @Published var ongoing: [Booking] = []
    @Published var completed: [Booking] = []
    @Published var pending: [Booking] = []
    @Published var history: [Booking] = []

    @Published var isLoading = false
    @Published var errorText: String?

    private let engine: Engine
    private var didLoadOnce = false

    init(engine: Engine) {
        self.engine = engine
    }

    // MARK: - Public API
    func loadIfNeeded() async {
        guard !didLoadOnce else { return }
        didLoadOnce = true
        await load()
    }

    func reload() async {
        await load()
    }

    // MARK: - Main Loader
    func load() async {
        isLoading = true
        defer { isLoading = false }

        let response = await engine.bookingService.getBookings(scope: nil, status: nil)

        switch response {
        case .success(let bookings):
            processBookings(bookings)
            StorageManager.shared.saveCachedBookings(bookings)

        case .failure(let err):
            let cache = StorageManager.shared.getCachedBookings()

            if !cache.isEmpty {
                processBookings(cache)
                errorText = R.string.localizable.apiErrorOfflineFallback()
            } else {
                errorText = err.localizedDescription
            }
        }
    }

    // MARK: - Processing
    private func processBookings(_ bookings: [Booking]) {
        self.allBookings = bookings

        let now = Date()

        var upcomingList: [Booking] = []
        var ongoingList: [Booking] = []
        var completedList: [Booking] = []
        var pendingList: [Booking] = []
        var historyList: [Booking] = []

        for booking in bookings {
            let start = DateFormatters.isoDateTime(date: booking.date, time: booking.startTime)
            let end   = DateFormatters.isoDateTime(date: booking.date, time: booking.endTime)

            // ————————————————
            // 1) Pending
            // ————————————————
            if booking.status == .pending {
                pendingList.append(booking)
                continue
            }

            // ————————————————
            // 2) Completed
            // ————————————————
            if booking.status == .completed {
                completedList.append(booking)
                historyList.append(booking)
                continue
            }

            // ————————————————
            // 3) Compare Dates
            // ————————————————
            if let start, let end {

                if end < now {
                    // Finished → goes to history
                    historyList.append(booking)
                }
                else if start > now {
                    // Future → upcoming
                    upcomingList.append(booking)
                }
                else if start <= now && now <= end {
                    // Active right now
                    ongoingList.append(booking)
                } else {
                    // fallback normal classification
                    upcomingList.append(booking)
                }

            } else {
                // Impossible de parser → fallback historique
                historyList.append(booking)
            }
        }

        // MARK: - Assign sorted lists
        self.pending = pendingList.sorted { $0.startTime < $1.startTime }
        self.upcoming = upcomingList.sorted { $0.startTime < $1.startTime }
        self.ongoing = ongoingList.sorted { $0.startTime < $1.startTime }
        self.completed = completedList.sorted { $0.startTime > $1.startTime }
        self.history = historyList.sorted { $0.date > $1.date }
    }
}
