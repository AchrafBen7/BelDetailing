//
//  UserService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Protocol
protocol UserService {
    // MARK: Auth
    var currentUser: User? { get set } // ✅ ajouté
    func register(payload: [String: Any]) async -> APIResponse<User>
    func login(email: String, password: String) async -> APIResponse<User>
    func refresh() async -> APIResponse<Bool>
    func me() async -> APIResponse<User>

    // MARK: Profile
    func updateProfile(data: [String: Any]) async -> APIResponse<User>

    // MARK: TVA Validation
    func validateVAT(_ number: String) async -> APIResponse<Bool>

    // MARK: Providers Discovery
    func providersNearby(lat: Double, lng: Double, radius: Double) async -> APIResponse<[Detailer]>
    func recommendedProviders(limit: Int?) async -> APIResponse<[Detailer]>
}

// MARK: - Network Implementation
final class UserServiceNetwork: UserService {
    var currentUser: User? // ✅ ajouté

    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    // MARK: Auth
    func register(payload: [String: Any]) async -> APIResponse<User> {
        let response: APIResponse<User> = await networkClient.call(endPoint: .register, dict: payload)
        if case let .success(user) = response {
            currentUser = user
        }
        return response
    }

    func login(email: String, password: String) async -> APIResponse<User> {
        let response: APIResponse<User> = await networkClient.call(
            endPoint: .login,
            dict: ["email": email, "password": password]
        )
        if case let .success(user) = response {
            currentUser = user
        }
        return response
    }

    func refresh() async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .refresh)
    }

    func me() async -> APIResponse<User> {
        let response: APIResponse<User> = await networkClient.call(endPoint: .profile)
        if case let .success(user) = response {
            currentUser = user
        }
        return response
    }

    func updateProfile(data: [String: Any]) async -> APIResponse<User> {
        let response: APIResponse<User> = await networkClient.call(endPoint: .updateProfile, dict: data)
        if case let .success(user) = response {
            currentUser = user
        }
        return response
    }

    // MARK: TVA Validation
    func validateVAT(_ number: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .vatValidate(number: number))
    }

    // MARK: Providers Discovery
    func providersNearby(lat: Double, lng: Double, radius: Double) async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .providersList,
            urlDict: ["lat": lat, "lng": lng, "radius": radius]
        )
    }

    func recommendedProviders(limit: Int?) async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .providersList,
            urlDict: ["sort": "rating,-priceMin", "limit": limit]
        )
    }
}

// MARK: - Mock Implementation
final class UserServiceMock: MockService, UserService {
    var currentUser: User? = .sampleProvider // ✅ par défaut prestataire pour voir le dashboard

    func register(payload: [String: Any]) async -> APIResponse<User> {
        await randomWait()
        let user = User.sampleCustomer
        currentUser = user
        return .success(user)
    }

    func login(email: String, password: String) async -> APIResponse<User> {
        await randomWait()
        let user = User.sampleCustomer
        currentUser = user
        return .success(user)
    }

    func refresh() async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }

    func me() async -> APIResponse<User> {
        await randomWait()
        return .success(currentUser ?? .sampleCustomer)
    }

    func updateProfile(data: [String: Any]) async -> APIResponse<User> {
        await randomWait()
        return .success(currentUser ?? .sampleCustomer)
    }

    func validateVAT(_ number: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(number.uppercased().hasPrefix("BE"))
    }

    func providersNearby(lat: Double, lng: Double, radius: Double) async -> APIResponse<[Detailer]> {
        await randomWait()
        return .success(Detailer.sampleValues)
    }

    func recommendedProviders(limit: Int?) async -> APIResponse<[Detailer]> {
        await randomWait()
        return .success(Detailer.sampleValues)
    }
}
