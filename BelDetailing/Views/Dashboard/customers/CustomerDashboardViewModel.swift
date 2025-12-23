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

    // MARK: - Bookings / Providers (existant)
    @Published var isLoadingBookings = false
    @Published var isLoadingProviders = false
    @Published var bookings: [Booking] = []
    @Published var providers: [Detailer] = []

    // MARK: - Shop (NOUVEAU)
    @Published var isLoadingProducts = false
    @Published var products: [Product] = []
    @Published var recommendedProducts: [Product] = []
    @Published var selectedCategory: ProductCategory? = nil

    let engine: Engine
    init(engine: Engine) { self.engine = engine }

    // MARK: - Header name
    var displayName: String {
        engine.userService.fullUser?.customerProfile?.firstName ?? "Customer"
    }

    // MARK: - Global loader
    func load() async {
        // On charge tout en parallèle
        async let bookingsTask: Void = loadBookings()
        async let providersTask: Void = loadProviders()
        async let shopTask: Void = loadShop()
        _ = await (bookingsTask, providersTask, shopTask)
    }

    // MARK: - Bookings
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

    // MARK: - Providers
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

    // MARK: - Shop
    func loadShop() async {
        async let rec: Void = loadRecommendedProducts()
        async let all: Void = loadProducts()
        _ = await (rec, all)
    }

    func loadRecommendedProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        let res = await engine.productService.getRecommended(limit: 6)
        if case let .success(list) = res {
            recommendedProducts = list
        } else {
            recommendedProducts = []
        }
    }

    func loadProducts() async {
        let res = await engine.productService.getProducts(
            category: selectedCategory,
            limit: nil
        )
        if case let .success(list) = res {
            products = list
        } else {
            products = []
        }
    }

    func trackProductClick(_ id: String) async {
        _ = await engine.productService.trackClick(productId: id)
    }

    // MARK: - Actions
    func onBookService() {
        // route vers SearchView(engine:) ou une page de booking directe
    }

    func onViewBookings() {
        // navigation vers BookingsView(engine:)
    }
}
