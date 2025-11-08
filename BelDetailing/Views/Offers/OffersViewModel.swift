//
//  OffersViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class OffersViewModel: ObservableObject {
  @Published var offers: [Offer] = []
  @Published var isLoading = false
  @Published var errorText: String?
  @Published var selectedStatus: OfferStatus? = nil
  @Published var selectedType: OfferType? = nil

  private let engine: Engine

  init(engine: Engine) { self.engine = engine }

  func load() async {
    isLoading = true; defer { isLoading = false }
    let res = await engine.offerService.getOffers(status: selectedStatus, type: selectedType)
    switch res {
    case .success(let list):
      self.offers = list
      StorageManager.shared.saveCachedOffers(list)
    case .failure(let err):
      let cache = StorageManager.shared.getCachedOffers()
      if !cache.isEmpty {
        offers = cache
        errorText = R.string.localizable.apiErrorOfflineFallback()
      } else {
        errorText = err.localizedDescription
      }
    }
  }

  func refreshFilters(status: OfferStatus?, type: OfferType?) async {
    selectedStatus = status
    selectedType = type
    await load()
  }
}
