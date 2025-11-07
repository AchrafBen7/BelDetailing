//
//  CityService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Protocol
protocol CityService {
    func cities() async -> APIResponse<[City]>
    func searchCities(query: String) async -> APIResponse<[City]>
    func getCityDetail(id: String) async -> APIResponse<City>
    func nearbyCities(lat: Double, lng: Double, radius: Double) async -> APIResponse<[City]>
}

// MARK: - Network Implementation
final class CityServiceNetwork: CityService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func cities() async -> APIResponse<[City]> {
        await networkClient.call(endPoint: .cities)
    }

    func searchCities(query: String) async -> APIResponse<[City]> {
        await networkClient.call(endPoint: .cities, urlDict: ["query": query])
    }

    func getCityDetail(id: String) async -> APIResponse<City> {
        await networkClient.call(endPoint: .cities, urlDict: ["id": id])
    }

    func nearbyCities(lat: Double, lng: Double, radius: Double) async -> APIResponse<[City]> {
        await networkClient.call(endPoint: .cities, urlDict: [
            "lat": lat,
            "lng": lng,
            "radius": radius
        ])
    }
}

// MARK: - Mock Implementation
final class CityServiceMock: MockService, CityService {
    func cities() async -> APIResponse<[City]> {
        await randomWait()
        return .success(City.sampleValues)
    }

    func searchCities(query: String) async -> APIResponse<[City]> {
        await randomWait()
        let results = City.sampleValues.filter { $0.name.lowercased().contains(query.lowercased()) }
        return .success(results)
    }

    func getCityDetail(id: String) async -> APIResponse<City> {
        await randomWait()
        guard let city = City.sampleValues.first(where: { $0.id == id }) else {
            return .failure(.serverError(statusCode: 404))
        }
        return .success(city)
    }

    func nearbyCities(lat: Double, lng: Double, radius: Double) async -> APIResponse<[City]> {
        await randomWait()
        // Simulation simple : retourner toutes les villes avec un rayon arbitraire
        return .success(City.sampleValues)
    }
}
