//
//  CustomerDashboardViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 18/12/2025.
//

import SwiftUI
import Combine
import RswiftResources
// MARK: - ViewModel
@MainActor
final class CustomerDashboardViewModel: ObservableObject {
    @Published var isLoadingBookings = false
    @Published var isLoadingProviders = false
    @Published var bookings: [Booking] = []
    @Published var providers: [Detailer] = []

    let engine: Engine
    init(engine: Engine) { self.engine = engine }

    var displayName: String {
        engine.userService.fullUser?.customerProfile?.firstName ?? "Customer"
    }

    func load() async {
        // Version async let propre
        async let bookingsTask: Void = loadBookings()
        async let providersTask: Void = loadProviders()
        _ = await (bookingsTask, providersTask)
    }

    func loadBookings() async {
        isLoadingBookings = true
        defer { isLoadingBookings = false }
        // Le backend filtre par "customer" et "upcoming"
        let resp = await engine.bookingService.getBookings(scope: "customer", status: "upcoming")
        if case let .success(list) = resp {
            bookings = list
        } else {
            bookings = []
        }
    }

    func loadProviders() async {
        isLoadingProviders = true
        defer { isLoadingProviders = false }
        let resp = await engine.userService.recommendedProviders(limit: 10)
        if case let .success(list) = resp {
            providers = list
        } else {
            providers = []
        }
    }

    // Actions
    func onBookService() {
        // route vers SearchView(engine:) ou une page de booking directe
    }

    func onViewBookings() {
        // navigation vers BookingsView(engine:)
    }
}
