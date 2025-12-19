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
    private var notificationToken: NSObjectProtocol?

    init(engine: Engine) {
        self.engine = engine

        // Observe local creation to update immediately
        notificationToken = NotificationCenter.default.addObserver(
            forName: .bookingCreated,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self else { return }
            if let newBooking = note.object as? Booking {
                self.handleCreated(booking: newBooking)
            } else {
                // Si on reçoit la notif sans objet, on peut forcer un reload réseau
                Task { await self.reload() }
            }
        }
    }

    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
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

        // 👉 On demande explicitement les bookings du customer connecté
        let response = await engine.bookingService.getBookings(scope: "customer", status: nil)

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

    // MARK: - Local insertion after creation
    private func handleCreated(booking: Booking) {
        // Merge: replace si même id, sinon append
        if let idx = allBookings.firstIndex(where: { $0.id == booking.id }) {
            allBookings[idx] = booking
        } else {
            allBookings.append(booking)
        }
        processBookings(allBookings)
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

            // Fallbacks pour heures manquantes
            let start = DateFormatters.isoDateTime(date: booking.date, time: booking.startTime ?? "00:00")
            let end   = DateFormatters.isoDateTime(date: booking.date, time: booking.endTime ?? "23:59")

            switch booking.status {

            case .pending:
                pendingList.append(booking)

            case .confirmed:
                if let start, let end {
                    if start > now {
                        upcomingList.append(booking)
                    } else if start <= now && now <= end {
                        ongoingList.append(booking)
                    } else {
                        historyList.append(booking)
                    }
                } else {
                    historyList.append(booking)
                }

            case .completed:
                completedList.append(booking)
                historyList.append(booking)

            case .declined, .cancelled:
                historyList.append(booking)
            }
        }

        // MARK: - Sorting helpers (robust with Date)
        func startDate(of book: Booking) -> Date? {
            DateFormatters.isoDateTime(date: book.date, time: book.startTime ?? "00:00")
        }
        func endDate(of book: Booking) -> Date? {
            DateFormatters.isoDateTime(date: book.date, time: book.endTime ?? "23:59")
        }

        // Generic ascending by start date, put nils last
        func sortByStartAscending(_ lhs: Booking, _ rhs: Booking) -> Bool {
            switch (startDate(of: lhs), startDate(of: rhs)) {
            case let (lif?, rey?): return lif < rey
            case (nil, _?):    return false
            case (_?, nil):    return true
            default:           return lhs.id < rhs.id
            }
        }

        // Generic descending by end date (fallback to start), put nils last
        func sortByEndDescending(_ lhs: Booking, _ rhs: Booking) -> Bool {
            let lEnd = endDate(of: lhs) ?? startDate(of: lhs)
            let rEnd = endDate(of: rhs) ?? startDate(of: rhs)
            switch (lEnd, rEnd) {
            case let (lif?, rey?): return lif > rey
            case (nil, _?):    return false
            case (_?, nil):    return true
            default:           return lhs.id < rhs.id
            }
        }

        // MARK: - Assign sorted lists
        self.pending   = pendingList.sorted(by: sortByStartAscending)
        self.upcoming  = upcomingList.sorted(by: sortByStartAscending)
        self.ongoing   = ongoingList.sorted(by: sortByStartAscending)
        self.completed = completedList.sorted(by: sortByEndDescending)
        self.history   = historyList.sorted(by: sortByEndDescending)
        
        // MARK: - Actions

        func cancelBooking(_ booking: Booking) async -> Bool {
            isLoading = true
            defer { isLoading = false }

            let response = await engine.bookingService.cancelBooking(id: booking.id)

            switch response {
            case .success:
                await reload()
                return true

            case .failure(let error):
                errorText = error.localizedDescription
                return false
            }
        }

    }
}
