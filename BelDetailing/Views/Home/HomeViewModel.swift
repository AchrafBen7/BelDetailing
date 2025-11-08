//
//  HomeViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import RswiftResources
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var errorText: String?
  @Published var recommended: [Detailer] = []
  @Published var cityName: String?

  private let engine: Engine

  init(engine: Engine) {
    self.engine = engine
  }

  func load() async {
    isLoading = true; defer { isLoading = false }
    do {
      let city = StorageManager.shared.getSelectedCity()
      cityName = city?.name
      let result = await engine.userService.recommendedProviders(limit: 10)
      switch result {
      case .success(let list):
        self.recommended = list
        StorageManager.shared.saveCachedProviders(list)
      case .failure(let err):
        let cache = StorageManager.shared.getCachedProviders()
        if !cache.isEmpty {
          self.recommended = cache
          self.errorText = R.string.localizable.apiErrorOfflineFallback()
        } else {
          self.errorText = err.localizedDescription
        }
      }
    }
  }
}
