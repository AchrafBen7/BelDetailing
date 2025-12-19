//
//  CompanyDashboardViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 18/12/2025.
//

import SwiftUI
import Combine
import RswiftResources

@MainActor
final class CompanyDashboardViewModel: ObservableObject {

    enum Tab {
        case marketplace
        case myOffers
    }

    @Published var selectedTab: Tab = .marketplace
    @Published var isLoading = false
    @Published var marketplaceOffers: [Offer] = []
    @Published var myOffers: [Offer] = []
    @Published var selectedOffer: Offer?

    // MARK: - Filtres
    @Published var selectedType: OfferType? = nil
    @Published var locationQuery: String = ""
    @Published var budgetMax: Double? = nil

    let engine: Engine
    init(engine: Engine) { self.engine = engine }

    var companyName: String {
        engine.userService.fullUser?.companyProfile?.legalName
        ?? "Entreprise"
    }

    func load() async {
        await loadMarketplaceOffers()
        await loadMyOffers()
    }

    private func loadMarketplaceOffers() async {
        isLoading = true
        defer { isLoading = false }

        let res = await engine.offerService.getOffers(status: .open, type: nil)
        if case let .success(list) = res {
            marketplaceOffers = list
        }
    }

    private func loadMyOffers() async {
        let res = await engine.offerService.getOffers(status: nil, type: nil)
        if case let .success(list) = res {
            myOffers = list
        }
    }

    func onCreateOffer() {
        // TODO: navigation vers CreateOfferView
    }

    func onSelectOffer(_ offer: Offer) {
        selectedOffer = offer
    }

    // MARK: - Données courantes selon onglet
    private var baseCurrentOffers: [Offer] {
        selectedTab == .marketplace ? marketplaceOffers : myOffers
    }

    // MARK: - Plage budget disponible (bornes auto)
    var availableBudgetRange: (min: Double, max: Double)? {
        let base = baseCurrentOffers
        guard !base.isEmpty else { return nil }
        let minValue = base.map { $0.priceMin }.min() ?? 0
        let maxValue = base.map { $0.priceMax }.max() ?? 0
        guard maxValue >= minValue else { return nil }
        return (minValue, maxValue)
    }

    // MARK: - Liste filtrée
    var filteredCurrentOffers: [Offer] {
        var result = baseCurrentOffers

        // 1) Type
        if let selectedType {
            result = result.filter { $0.type == selectedType }
        }

        // 2) Localisation (ville / CP)
        let que = locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !que.isEmpty {
            let lower = que.lowercased()
            result = result.filter { offer in
                offer.city.lowercased().contains(lower)
                || offer.postalCode.lowercased().contains(lower)
            }
        }

        // 3) Budget max (on garde les offres dont l'intervalle chevauche 0...budgetMax)
        if let budgetMax {
            result = result.filter { offer in
                // On retient si l'offre a un prix min <= budgetMax
                offer.priceMin <= budgetMax
            }
        }

        return result
    }

    // MARK: - Helpers filtres
    func resetFilters() {
        selectedType = nil
        locationQuery = ""
        budgetMax = nil
    }
}

