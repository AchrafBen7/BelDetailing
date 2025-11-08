//
//  SearchViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
  @Published var query = ""
  @Published var city: String?
  @Published var maxPrice: Double?
  @Published var atHome = false
  @Published var isLoading = false
  @Published var results: [Detailer] = []
  @Published var errorText: String?

  private let engine: Engine

  init(engine: Engine) { self.engine = engine }

  func search() async {
    isLoading = true; defer { isLoading = false }
    let res = await engine.searchService.searchProviders(
      query: query.isEmpty ? nil : query,
      city: city,
      lat: nil, lng: nil,
      radius: nil
    )
      switch res {
      case .success(let list):
        // simpele client-side filtering (prijs, service aan huis)
        self.results = list.filter { detailer in
          let priceOK = maxPrice == nil || detailer.minPrice <= (maxPrice ?? .greatestFiniteMagnitude)
          let mobileOK = !atHome || detailer.hasMobileService
          return priceOK && mobileOK
        }
      case .failure(let err):
        self.errorText = err.localizedDescription
      }

  }
}
