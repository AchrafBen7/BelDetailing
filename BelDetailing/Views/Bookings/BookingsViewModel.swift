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

    // MARK: - Actions (public instance methods)
    func acceptCounterProposal(bookingId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let response = await engine.bookingService.acceptCounterProposal(bookingId: bookingId)
        switch response {
        case .success:
            await reload()
        case .failure(let error):
            errorText = error.localizedDescription
        }
    }
    
    func refuseCounterProposal(bookingId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let response = await engine.bookingService.refuseCounterProposal(bookingId: bookingId)
        switch response {
        case .success:
            await reload()
        case .failure(let error):
            errorText = error.localizedDescription
        }
    }

    // MARK: - Main Loader
    func load() async {
        isLoading = true
        errorText = nil // ✅ Réinitialiser l'erreur au début du chargement
        defer { isLoading = false }

        // Nettoyer les bookings expirés (>6h pending) avant de charger
        // ⚠️ Ne pas bloquer si cette requête échoue (c'est optionnel)
        let cleanupResult = await engine.bookingService.cleanupExpiredBookings()
        if case .failure(let err) = cleanupResult, !err.isCancellation {
            // Ignorer les erreurs d'annulation, mais logger les autres
            print("⚠️ [BookingsViewModel] cleanupExpiredBookings failed: \(err.localizedDescription ?? "unknown")")
        }

        // 👉 Déterminer le scope selon le rôle de l'utilisateur
        let scope: String?
        if let user = AppSession.shared.user {
            switch user.role {
            case .customer:
                scope = "customer"
            case .provider:
                scope = "provider"
            case .company:
                scope = nil // Companies ne voient pas de bookings normalement
            }
        } else {
            // Fallback: essayer de récupérer le rôle depuis UserService
            if let cachedUser = engine.userService.fullUser {
                switch cachedUser.role {
                case .customer:
                    scope = "customer"
                case .provider:
                    scope = "provider"
                case .company:
                    scope = nil
                }
            } else {
                // Par défaut, essayer customer
                scope = "customer"
            }
        }

        let response = await engine.bookingService.getBookings(scope: scope, status: nil)

        switch response {
        case .success(var bookings):
            // Filtrage supplémentaire côté client pour sécurité
            bookings = filterBookingsByRole(bookings)
            processBookings(bookings)
            StorageManager.shared.saveCachedBookings(bookings)
            // ✅ Succès : effacer toute erreur précédente
            errorText = nil

        case .failure(let err):
            // ✅ Ignorer les erreurs "cancelled" - ce ne sont pas de vraies erreurs réseau
            if err.isCancellation {
                // Si on a des données en cache, les utiliser
                let cache = StorageManager.shared.getCachedBookings()
                let filteredCache = filterBookingsByRole(cache)
                if !filteredCache.isEmpty {
                    processBookings(filteredCache)
                }
                errorText = nil // Ne pas afficher d'erreur pour une annulation
                return
            }
            
            let cache = StorageManager.shared.getCachedBookings()
            let filteredCache = filterBookingsByRole(cache)

            if !filteredCache.isEmpty {
                // ✅ Cache disponible : afficher les données et ne PAS afficher d'erreur
                processBookings(filteredCache)
                errorText = nil // Ne pas afficher d'erreur si on a des données en cache
            } else {
                // ❌ Pas de cache : afficher l'erreur
                errorText = err.localizedDescription
            }
        }
    }
    
    // MARK: - Filter Bookings by Role
    private func filterBookingsByRole(_ bookings: [Booking]) -> [Booking] {
        guard let user = AppSession.shared.user ?? engine.userService.fullUser else {
            return bookings
        }
        
        let userId = user.id
        
        switch user.role {
        case .customer:
            // Customer: voir uniquement les bookings où il est le customer
            return bookings.filter { booking in
                booking.customerId == userId
            }
            
        case .provider:
            // Provider: voir uniquement les bookings où il est le provider
            return bookings.filter { booking in
                booking.providerId == userId
            }
            
        case .company:
            // Company: pas de bookings normalement
            return []
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
        let now = Date()

        var upcomingList: [Booking] = []
        var ongoingList: [Booking] = []
        var completedList: [Booking] = []
        var pendingList: [Booking] = []
        var historyList: [Booking] = []
        var allFilteredList: [Booking] = [] // For "all" tab with past filtering

        for booking in bookings {

            // Fallbacks pour heures manquantes
            let start = DateFormatters.isoDateTime(date: booking.date, time: booking.startTime ?? "00:00")
            let end   = DateFormatters.isoDateTime(date: booking.date, time: booking.endTime ?? "23:59")
            
            // Check if booking is past
            let isPast = booking.isPast

            switch booking.status {

            case .pending:
                // Exclure les bookings expirés (>6h sans acceptation/refus)
                if booking.isExpired {
                    // Ne pas ajouter aux listes - disparaît visuellement et sera supprimé du backend
                    continue
                }
                // If past and pending, exclude from all (can disappear)
                if !isPast {
                    pendingList.append(booking)
                    allFilteredList.append(booking)
                }
                // If past, we don't add it anywhere (it disappears)

            case .confirmed:
                if let start, let end {
                    if start > now {
                        upcomingList.append(booking)
                        allFilteredList.append(booking)
                    } else if start <= now && now <= end {
                        ongoingList.append(booking)
                        allFilteredList.append(booking)
                    } else {
                        // Past confirmed booking -> exclude from "all" but add to history
                        historyList.append(booking)
                    }
                } else {
                    // No valid dates -> add to history only
                    historyList.append(booking)
                }

            case .started, .inProgress:
                ongoingList.append(booking)
                allFilteredList.append(booking)

            case .completed:
                completedList.append(booking)
                historyList.append(booking)
                // Completed bookings are shown in "all" as they're still relevant
                allFilteredList.append(booking)

            case .declined:
                // Declined bookings: peuvent être annulés (mais pas de refund car preauthorized)
                // On les montre dans "all" pour que le customer puisse les annuler s'il veut
                historyList.append(booking)
                allFilteredList.append(booking)
                
            case .cancelled:
                historyList.append(booking)
                // Cancelled: déjà annulé, on ne les montre pas dans "all"
            }
        }
        
        // Set allBookings to filtered list (without past confirmed/pending)
        self.allBookings = allFilteredList

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
    }
}

