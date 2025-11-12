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

  private let engine: Engine

  init(engine: Engine) {
    self.engine = engine
  }

  func load() async {
    isLoading = true; defer { isLoading = false }

    do {
      // 1️⃣ Charger les recommandés
      let result = await engine.userService.recommendedProviders(limit: 10)
      switch result {
      case .success(let list):
        self.recommended = list
        StorageManager.shared.saveCachedProviders(list)
      case .failure:
        let cache = StorageManager.shared.getCachedProviders()
        if !cache.isEmpty {
          self.recommended = cache
          self.errorText = R.string.localizable.apiErrorOfflineFallback()
        }
      }

      // 2️⃣ Charger tous les prestataires (mock local pour le moment)
      self.allDetailers = Detailer.sampleValues

    } catch {
      self.errorText = error.localizedDescription
    }
  }

  /// Filtrage local selon le type sélectionné
  func filtered(by filter: DetailingFilter) -> [Detailer] {
    guard filter != .all else { return allDetailers }
    let matchingCategories = filter.relatedCategories
    return allDetailers.filter { detailer in
      detailer.serviceCategories.contains { matchingCategories.contains($0) }
    }
  }
}
