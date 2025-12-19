//
//  DetailerService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

// MARK: - Protocol
protocol DetailerService {
    func getProfile(id: String) async -> APIResponse<Detailer>
    func updateProfile(id: String, data: [String: Any]) async -> APIResponse<Detailer>
    func getReviews(id: String) async -> APIResponse<[Review]>

    // Dashboard (JWT-based)
    func getMyStats() async -> APIResponse<DetailerStats>
    func getMyServices() async -> APIResponse<[Service]>

    // Legacy/id-based (public provider detail screens)
    func getStats(id: String) async -> APIResponse<DetailerStats>
    func getServices(id: String) async -> APIResponse<[Service]>
}

// MARK: - Network Implementation
final class DetailerServiceNetwork: DetailerService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getProfile(id: String) async -> APIResponse<Detailer> {
        await networkClient.call(endPoint: .providerDetail(id: id))
    }

    func updateProfile(id: String, data: [String: Any]) async -> APIResponse<Detailer> {
        await networkClient.call(endPoint: .updateProfile, dict: data)
    }

    func getReviews(id: String) async -> APIResponse<[Review]> {
        await networkClient.call(endPoint: .providerReviews(providerId: id))
    }

    // MARK: JWT-based for the logged-in provider
    func getMyStats() async -> APIResponse<DetailerStats> {
        await networkClient.call(endPoint: .providerMyStats)
    }

    func getMyServices() async -> APIResponse<[Service]> {
        await networkClient.call(endPoint: .providerMyServices)
    }

    // MARK: Legacy/id-based (still used on public provider screens)
    func getStats(id: String) async -> APIResponse<DetailerStats> {
        await networkClient.call(endPoint: .providerStats(providerId: id))
    }

    func getServices(id: String) async -> APIResponse<[Service]> {
        await networkClient.call(endPoint: .providerServices(providerId: id))
    }
}

// MARK: - Mock Implementation
final class DetailerServiceMock: MockService, DetailerService {
    func getProfile(id: String) async -> APIResponse<Detailer> {
        await randomWait()
        guard let detailer = Detailer.sampleValues.first(where: { $0.id == id }) else {
            return .failure(.serverError(statusCode: 404))
        }
        return .success(detailer)
    }

    func updateProfile(id: String, data: [String: Any]) async -> APIResponse<Detailer> {
        await randomWait()
        return .success(Detailer.sampleValues.first!)
    }

    func getReviews(id: String) async -> APIResponse<[Review]> {
        await randomWait()
        return .success(Review.sampleValues)
    }

    func getMyStats() async -> APIResponse<DetailerStats> {
        await randomWait()
        return .failure(.serverError(statusCode: 501))
    }

    func getMyServices() async -> APIResponse<[Service]> {
        await randomWait()
        return .success(Service.sampleValues)
    }

    func getStats(id: String) async -> APIResponse<DetailerStats> {
        await randomWait()
        return .failure(.serverError(statusCode: 501))
    }

    func getServices(id: String) async -> APIResponse<[Service]> {
        await randomWait()
        return .success(Service.sampleValues)
    }
}
