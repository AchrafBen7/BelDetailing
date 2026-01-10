//
//  UserService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

struct ProfileResponse: Codable {
    let user: User
}

struct EmptyResponse: Codable {}

// MARK: - VAT Lookup Response
struct VatLookupResponse: Codable {
    let valid: Bool
    let companyName: String?
    let address: String?
    let city: String?
    let postalCode: String?
    let country: String?
    let vatNumber: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case valid
        case companyName
        case address
        case city
        case postalCode
        case country
        case vatNumber
        case error
    }
}



// MARK: - Protocol
protocol UserService {
    // MARK: Auth
    var currentUser: UserLite? { get set }
    var fullUser: User? { get set }

    func register(payload: [String: Any]) async -> APIResponse<RegisterResponse>
    func login(email: String, password: String) async -> APIResponse<AuthSession>
    func refresh() async -> APIResponse<AuthSession>
    func me() async -> APIResponse<User>
    func logout() async -> APIResponse<Bool>
    func resendConfirmationEmail(email: String) async -> APIResponse<Bool>
    func verifyEmail(email: String, code: String) async -> APIResponse<Bool>

    // Social
    func loginWithApple(
        identityToken: String,
        authorizationCode: String?,
        fullName: String?,
        email: String?
    ) async -> APIResponse<AuthSession>

    func loginWithGoogle(idToken: String) async -> APIResponse<AuthSession>

    // Profile & TVA
    func updateProfile(data: [String: Any]) async -> APIResponse<User>
    func validateVAT(_ number: String) async -> APIResponse<Bool>
    func lookupVAT(_ vatNumber: String) async -> APIResponse<VatLookupResponse>

    // Providers
    func providersNearby(lat: Double, lng: Double, radius: Double) async -> APIResponse<[Detailer]>
    func recommendedProviders(limit: Int?) async -> APIResponse<[Detailer]>
    func allProviders() async -> APIResponse<[Detailer]>
}

// MARK: - Network Implementation
final class UserServiceNetwork: UserService {
    var currentUser: UserLite?
    var fullUser: User?

    private let networkClient: NetworkClientProtocol
    init(networkClient: NetworkClientProtocol) {
            self.networkClient = networkClient
        }

    // MARK: - Helpers
    private func handleAuthSuccess(_ session: AuthSession) {
        currentUser = session.user

        StorageManager.shared.saveAccessToken(session.accessToken)
        StorageManager.shared.saveRefreshToken(session.refreshToken)

        NetworkClient.defaultHeaders["Authorization"] = "Bearer \(session.accessToken)"
    }

    // MARK: - Auth

    func register(payload: [String: Any]) async -> APIResponse<RegisterResponse> {
        await networkClient.call(endPoint: .register, dict: payload)
    }

    func login(email: String, password: String) async -> APIResponse<AuthSession> {
        let response: APIResponse<AuthSession> = await networkClient.call(
            endPoint: .login,
            dict: ["email": email, "password": password]
        )
        if case let .success(session) = response {
            handleAuthSuccess(session)
        }
        return response
    }

    func refresh() async -> APIResponse<AuthSession> {
        let storedRefresh = StorageManager.shared.getRefreshToken() ?? ""

        let response: APIResponse<AuthSession> = await networkClient.call(
            endPoint: .refresh,
            dict: ["refreshToken": storedRefresh],
            allowAutoRefresh: false
        )
        if case let .success(session) = response {
            handleAuthSuccess(session)
        }
        return response
    }

    func me() async -> APIResponse<User> {
        let response: APIResponse<ProfileResponse> = await networkClient.call(endPoint: .profile)

        switch response {
        case .success(let payload):
            self.fullUser = payload.user
            return .success(payload.user)

        case .failure(let error):
            return .failure(error)
        }
    }
    
    func logout() async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .logout,
            dict: nil
        )

        switch response {
        case .success:
            StorageManager.shared.clearSession()
            currentUser = nil
            fullUser = nil
            NetworkClient.defaultHeaders["Authorization"] = nil
            return .success(true)

        case .failure(let err):
            return .failure(err)
        }
    }

    func resendConfirmationEmail(email: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .resendVerificationEmail,
            dict: ["email": email]
        )

        switch response {
        case .success:
            return .success(true)
        case .failure(let err):
            return .failure(err)
        }
    }
    
    func verifyEmail(email: String, code: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .verifyEmail,
            dict: ["email": email, "code": code]
        )

        switch response {
        case .success:
            return .success(true)
        case .failure(let err):
            return .failure(err)
        }
    }

    func updateProfile(data: [String: Any]) async -> APIResponse<User> {
        let response: APIResponse<ProfileResponse> = await networkClient.call(
            endPoint: .updateProfile,
            dict: data
        )

        switch response {
        case .success(let payload):
            self.fullUser = payload.user
            return .success(payload.user)

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Social

    func loginWithApple(
        identityToken: String,
        authorizationCode: String?,
        fullName: String?,
        email: String?
    ) async -> APIResponse<AuthSession> {

        var dict: [String: Any] = [
            "identityToken": identityToken
        ]
        if let authorizationCode { dict["authorizationCode"] = authorizationCode }
        if let fullName { dict["fullName"] = fullName }
        if let email { dict["email"] = email }

        let response: APIResponse<AuthSession> = await networkClient.call(
            endPoint: .loginApple,
            dict: dict
        )
        if case let .success(session) = response {
            handleAuthSuccess(session)
        }
        return response
    }

    func loginWithGoogle(idToken: String) async -> APIResponse<AuthSession> {
        let response: APIResponse<AuthSession> = await networkClient.call(
            endPoint: .loginGoogle,
            dict: ["idToken": idToken]
        )
        if case let .success(session) = response {
            handleAuthSuccess(session)
        }
        return response
    }

    // MARK: - TVA + Providers

    func validateVAT(_ number: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .vatValidate(number: number))
    }
    
    // MARK: - VAT Lookup (avec pré-remplissage)
    
    func lookupVAT(_ vatNumber: String) async -> APIResponse<VatLookupResponse> {
        await networkClient.call(
            endPoint: .vatLookup,
            dict: ["vatNumber": vatNumber],
            wrappedInData: false
        )
    }

    func providersNearby(lat: Double, lng: Double, radius: Double) async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .providersList,
            urlDict: ["lat": lat, "lng": lng, "radius": radius],
            wrappedInData: true
        )
    }

    func recommendedProviders(limit: Int?) async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .providersList,
            urlDict: ["sort": "rating,-priceMin", "limit": limit],
            wrappedInData: true
        )
    }

    func allProviders() async -> APIResponse<[Detailer]> {
        await networkClient.call(
            endPoint: .providersList,
            wrappedInData: true
        )
    }
}
