//  OffersViewModel.swift
//  BelDetailing

import Foundation
import Combine
import RswiftResources

enum QuickOfferFilter {
    case all
    case open
    case recent
}

@MainActor
final class OffersViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false
    @Published var errorText: String?

    // Filtres API (sheet)
    @Published var selectedStatus: OfferStatus? = nil
    @Published var selectedType: OfferType? = nil

    // Recherche locale
    @Published var locationQuery: String = ""

    // Filtres rapides (chips)
    @Published var selectedQuickFilter: QuickOfferFilter = .all

    private let engine: Engine

    /// Liste complète après appel API (et filtres du sheet)
    private var allOffersBackup: [Offer] = []

    init(engine: Engine) {
        self.engine = engine
    }

    // MARK: - API Load + Offline fallback
    func load() async {
        isLoading = true
        defer { isLoading = false }

        let res = await engine.offerService.getOffers(
            status: selectedStatus,
            type: selectedType
        )

        switch res {
        case .success(let list):
            allOffersBackup = list
            recomputeVisibleOffers()
            StorageManager.shared.saveCachedOffers(list)

        case .failure(let err):
            let cache = StorageManager.shared.getCachedOffers()
            if !cache.isEmpty {
                allOffersBackup = cache
                recomputeVisibleOffers()
                errorText = R.string.localizable.apiErrorOfflineFallback()
            } else {
                errorText = err.localizedDescription
            }
        }
    }

    // MARK: - API Filters (sheet)
    func refreshFilters(status: OfferStatus?, type: OfferType?) async {
        selectedStatus = status
        selectedType = type
        await load()
    }

    // MARK: - Local filter (ville / CP)
    func filterByLocation() {
        recomputeVisibleOffers()
    }

    // MARK: - Quick filters (chips)
    func applyQuickFilter(_ filter: QuickOfferFilter) {
        selectedQuickFilter = filter
        recomputeVisibleOffers()
    }

    // MARK: - Combine tous les filtres locaux
    private func recomputeVisibleOffers() {
        var base = allOffersBackup

        // 1) Quick filter
        switch selectedQuickFilter {
        case .all:
            break

        case .open:
            base = base.filter { $0.status == .open }

        case .recent:
            // createdAt est en ISO → tri lexicographique fonctionne
            base = base.sorted { $0.createdAt > $1.createdAt }
        }

        // 2) Filtre ville / code postal
        let query = locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            let lower = query.lowercased()
            base = base.filter { offer in
                offer.city.lowercased().contains(lower)
                || offer.postalCode.lowercased().contains(lower)
            }
        }

        offers = base
    }
}
