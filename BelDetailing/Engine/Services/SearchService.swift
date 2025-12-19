//
//  SearchService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

protocol SearchService {
    func searchProviders(query: String?, city: String?, lat: Double?, lng: Double?, radius: Double?) async -> APIResponse<[Detailer]>
    func searchOffers(query: String?, city: String?, category: String?) async -> APIResponse<[Offer]>
}

final class SearchServiceNetwork: SearchService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func searchProviders(
        query: String?, city: String?, lat: Double?, lng: Double?, radius: Double?
    ) async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .searchProviders,
            urlDict: [
                "q": query,
                "city": city,
                "lat": lat,
                "lng": lng,
                "radius": radius
            ],
            wrappedInData: true
        )
    }

    func searchOffers(query: String?, city: String?, category: String?) async -> APIResponse<[Offer]> {
        await networkClient.call(
            endPoint: .searchOffers,
            urlDict: [
                "q": query,
                "city": city,
                "category": category
            ],
            wrappedInData: true
        )
    }
}

