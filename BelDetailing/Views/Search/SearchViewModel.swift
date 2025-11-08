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
      // simple filtrage client pour l’exemple (prix, service à domicile)
      self.results = list.filter { d in
        let priceOK = maxPrice == nil || d.minPrice <= (maxPrice ?? .greatestFiniteMagnitude)
        let mobileOK = !atHome || d.hasMobileService
        return priceOK && mobileOK
      }
    case .failure(let err):
      self.errorText = err.localizedDescription
    }
  }
}
