//
//  HomeViewModel.swift
//  BelDetailing
//

import Foundation
import RswiftResources
import Combine
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorText: String?
    @Published var recommended: [Detailer] = []
    @Published var allDetailers: [Detailer] = []

    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }

    func load() async {
        isLoading = true; defer { isLoading = false }
        errorText = nil

        // 1️⃣ Recommandés
        let recommendedResult = await engine.userService.recommendedProviders(limit: 10)
        switch recommendedResult {
        case .success(let list):
            self.recommended = list
            StorageManager.shared.saveCachedProviders(list) // cache basic
        case .failure:
            let cache = StorageManager.shared.getCachedProviders()
            if !cache.isEmpty {
                self.recommended = cache
                self.errorText = R.string.localizable.apiErrorOfflineFallback()
            }
        }

        // 2️⃣ Tous les prestataires
        let allResult = await engine.userService.allProviders()
        switch allResult {
        case .success(let list):
            self.allDetailers = list
        case .failure:
            // en fallback, on peut au moins montrer les recommandés comme "all"
            if !recommended.isEmpty {
                self.allDetailers = recommended
            } else {
                // ultimate fallback: samples (optioneel)
                self.allDetailers = Detailer.sampleValues
            }
        }
    }

    func filtered(by filter: DetailingFilter) -> [Detailer] {
        guard filter != .all else { return allDetailers }
        let matchingCategories = filter.relatedCategories
        return allDetailers.filter { detailer in
            detailer.serviceCategories.contains { matchingCategories.contains($0) }
        }
    }
}
