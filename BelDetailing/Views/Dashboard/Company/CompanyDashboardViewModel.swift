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

        print("🔄 [CompanyDashboardVM] Loading marketplace offers...")
        let res = await engine.offerService.getOffers(status: .open, type: nil)
        switch res {
        case .success(let list):
            print("✅ [CompanyDashboardVM] Loaded \(list.count) marketplace offers")
            marketplaceOffers = list
            if let first = list.first {
                print("ℹ️ [CompanyDashboardVM] First offer: \(first.id) - \(first.title)")
            }
        case .failure(let error):
            print("❌ [CompanyDashboardVM] Error loading marketplace offers: \(error)")
            marketplaceOffers = []
        }
    }

    private func loadMyOffers() async {
        print("🔄 [CompanyDashboardVM] Loading my offers...")
        let res = await engine.offerService.getOffers(status: nil, type: nil)
        switch res {
        case .success(let list):
            print("✅ [CompanyDashboardVM] Loaded \(list.count) total offers")
            // Filtrer pour ne garder que les offres créées par cette company
            if let currentUserId = engine.userService.fullUser?.id {
                myOffers = list.filter { $0.createdBy == currentUserId }
                print("✅ [CompanyDashboardVM] Filtered to \(myOffers.count) my offers (createdBy: \(currentUserId))")
            } else {
                print("⚠️ [CompanyDashboardVM] No current user ID, cannot filter my offers")
                myOffers = []
            }
        case .failure(let error):
            print("❌ [CompanyDashboardVM] Error loading my offers: \(error)")
            myOffers = []
        }
    }

    @Published var showCreateOffer = false
    
    func onCreateOffer() {
        showCreateOffer = true
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
        print("🔍 [CompanyDashboardVM] Filtering offers - base: \(result.count), tab: \(selectedTab)")

        // 1) Type
        if let selectedType {
            let before = result.count
            result = result.filter { $0.type == selectedType }
            print("🔍 [CompanyDashboardVM] After type filter (\(selectedType)): \(before) -> \(result.count)")
        }

        // 2) Localisation (ville / CP)
        let que = locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !que.isEmpty {
            let before = result.count
            let lower = que.lowercased()
            result = result.filter { offer in
                offer.city.lowercased().contains(lower)
                || offer.postalCode.lowercased().contains(lower)
            }
            print("🔍 [CompanyDashboardVM] After location filter ('\(que)'): \(before) -> \(result.count)")
        }

        // 3) Budget max (on garde les offres dont l'intervalle chevauche 0...budgetMax)
        if let budgetMax {
            let before = result.count
            result = result.filter { offer in
                // On retient si l'offre a un prix min <= budgetMax
                offer.priceMin <= budgetMax
            }
            print("🔍 [CompanyDashboardVM] After budget filter (≤\(budgetMax)): \(before) -> \(result.count)")
        }

        print("✅ [CompanyDashboardVM] Final filtered offers: \(result.count)")
        return result
    }

    // MARK: - Helpers filtres
    func resetFilters() {
        selectedType = nil
        locationQuery = ""
        budgetMax = nil
    }
}

