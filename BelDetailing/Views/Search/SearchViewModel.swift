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
    @Published var cities: [City] = []
    private let engine: Engine
    init(engine: Engine) { self.engine = engine }
    func loadCities() async {
        let res = await engine.cityService.cities()
        if case .success(let list) = res { self.cities = list }
    }
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

extension SearchViewModel {
  func resetFilters() {
    query = ""
    city = nil
    maxPrice = nil
    atHome = false
  }
}
