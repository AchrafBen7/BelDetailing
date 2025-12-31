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
    func createMyService(data: [String: Any?]) async -> APIResponse<Service>

    // Legacy/id-based (public provider detail screens)
    func getStats(id: String) async -> APIResponse<DetailerStats>
    func getServices(id: String) async -> APIResponse<[Service]>

    // NEW: Update logged-in provider profile (/providers/me)
    func updateMyProfile(data: [String: Any]) async -> APIResponse<Detailer>
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
        let res: APIResponse<[ProviderServiceDTO]> = await networkClient.call(endPoint: .providerMyServices)
        switch res {
        case .success(let dtos):
            let mapped = dtos.compactMap { $0.toDomain() }
            return .success(mapped)
        case .failure(let err):
            return .failure(err)
        }
    }

    func createMyService(data: [String: Any?]) async -> APIResponse<Service> {
        let res: APIResponse<ProviderServiceDTO> = await networkClient.call(endPoint: .providerServiceCreate, dict: data)
        switch res {
        case .success(let dto):
            if let service = dto.toDomain() {
                return .success(service)
            } else {
                return .failure(.decodingError(decodingError: NSError(domain: "DetailerServiceNetwork", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid category value: \(dto.category)"
                ])))
            }
        case .failure(let err):
            return .failure(err)
        }
    }

    // MARK: Legacy/id-based (still used on public provider screens)
    func getStats(id: String) async -> APIResponse<DetailerStats> {
        await networkClient.call(endPoint: .providerStats(providerId: id))
    }

    func getServices(id: String) async -> APIResponse<[Service]> {
        await networkClient.call(endPoint: .providerServices(providerId: id))
    }

    // MARK: NEW: Update logged-in provider profile
    func updateMyProfile(data: [String: Any]) async -> APIResponse<Detailer> {
        await networkClient.call(endPoint: .providerMeUpdate, dict: data)
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

    func createMyService(data: [String : Any?]) async -> APIResponse<Service> {
        await randomWait()
        return .success(Service.sampleValues.first!)
    }

    func getStats(id: String) async -> APIResponse<DetailerStats> {
        await randomWait()
        return .failure(.serverError(statusCode: 501))
    }

    func getServices(id: String) async -> APIResponse<[Service]> {
        await randomWait()
        return .success(Service.sampleValues)
    }

    func updateMyProfile(data: [String : Any]) async -> APIResponse<Detailer> {
        await randomWait()
        return .success(Detailer.sampleValues.first!)
    }
}

