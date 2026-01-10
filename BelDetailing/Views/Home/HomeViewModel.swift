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

        print("🔵 [HomeVM] load() BEGIN")

        // 1️⃣ Recommandés
        print("🔵 [HomeVM] fetching recommendedProviders(limit:10)")
        let recommendedResult = await engine.userService.recommendedProviders(limit: 10)
        switch recommendedResult {
        case .success(let list):
            print("✅ [HomeVM] recommendedProviders success, count:", list.count)
            if let first = list.first {
                print("ℹ️ [HomeVM] first recommended:", first.id, first.displayName, "minPrice:", String(describing: first.minPrice), "rating:", first.rating, "cats:", first.serviceCategories)
            }
            self.recommended = list
            StorageManager.shared.saveCachedProviders(list) // cache basic
        case .failure(let err):
            print("❌ [HomeVM] recommendedProviders failure:", err)
            let cache = StorageManager.shared.getCachedProviders()
            print("ℹ️ [HomeVM] cached providers count:", cache.count)
            if !cache.isEmpty {
                self.recommended = cache
                self.errorText = R.string.localizable.apiErrorOfflineFallback()
            }
        }

        // 2️⃣ Tous les prestataires
        print("🔵 [HomeVM] fetching allProviders()")
        let allResult = await engine.userService.allProviders()
        switch allResult {
        case .success(let list):
            print("✅ [HomeVM] allProviders success, count:", list.count)
            if let first = list.first {
                print("ℹ️ [HomeVM] first all:", first.id, first.displayName, "minPrice:", String(describing: first.minPrice), "rating:", first.rating, "cats:", first.serviceCategories)
            }
            self.allDetailers = list
        case .failure(let err):
            print("❌ [HomeVM] allProviders failure:", err)
            // en fallback, on peut au moins montrer les recommandés comme "all"
            if !recommended.isEmpty {
                print("ℹ️ [HomeVM] using recommended as all, count:", recommended.count)
                self.allDetailers = recommended
            } 
        }

        print("🔵 [HomeVM] load() END — recommended:", recommended.count, "all:", allDetailers.count)
    }

    func filtered(by filter: DetailingFilter) -> [Detailer] {
        print("🔎 [HomeVM] filtered(by: \(filter)) — allDetailers count:", allDetailers.count)

        guard filter != .all else {
            let result = allDetailers
            print("🧮 [Home] filtered for \(filter) -> \(result.count) / total \(allDetailers.count)")
            if let first = result.first {
                print("ℹ️ [HomeVM] first after filter(.all):", first.id, first.displayName, "minPrice:", String(describing: first.minPrice), "rating:", first.rating, "cats:", first.serviceCategories)
            }
            return result
        }

        let matchingCategories = filter.relatedCategories
        print("ℹ️ [HomeVM] matchingCategories for \(filter):", matchingCategories)

        let result = allDetailers.filter { detailer in
            // Si le provider n'a pas de catégories, on le garde (ne pas exclure par défaut)
            guard !detailer.serviceCategories.isEmpty else {
                return true
            }
            // S'il a des catégories, au moins une doit matcher
            return detailer.serviceCategories.contains { matchingCategories.contains($0) }
        }

        print("🧮 [Home] filtered for \(filter) -> \(result.count) / total \(allDetailers.count)")
        if let first = result.first {
            print("ℹ️ [HomeVM] first after filter(\(filter)):", first.id, first.displayName, "minPrice:", String(describing: first.minPrice), "rating:", first.rating, "cats:", first.serviceCategories)
        }
        return result
    }
}
