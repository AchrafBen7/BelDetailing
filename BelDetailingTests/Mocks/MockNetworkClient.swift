//
//  MockNetworkClient.swift
//  BelDetailingTests
//
//  Created on 01/01/2026.
//

import Foundation
@testable import BelDetailing

/// Mock NetworkClient pour les tests
final class MockNetworkClient: NetworkClientProtocol {
    var responses: [APIEndPoint: Result<Data, APIError>] = [:]
    var callCount: [APIEndPoint: Int] = [:]
    
    func call<T: Decodable>(
        endPoint: APIEndPoint,
        dict: [String: Any?]? = nil,
        urlDict: [String: Any?]? = nil,
        additionalHeaders: [String: String]? = nil,
        timeout: TimeInterval = 60,
        allowAutoRefresh: Bool = true,
        wrappedInData: Bool = false
    ) async -> APIResponse<T> {
        callCount[endPoint, default: 0] += 1
        
        if let result = responses[endPoint] {
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    // Si wrappedInData, décoder depuis { data: T }
                    if wrappedInData {
                        let wrapper = try decoder.decode(APIContainer<T>.self, from: data)
                        return .success(wrapper.data)
                    } else {
                        // Essayer de décoder directement
                        let decoded = try decoder.decode(T.self, from: data)
                        return .success(decoded)
                    }
                } catch {
                    // Si échec, essayer avec wrapper (fallback)
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let wrapper = try decoder.decode(APIContainer<T>.self, from: data)
                        return .success(wrapper.data)
                    } catch {
                        return .failure(.decodingError(error.localizedDescription))
                    }
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .failure(.unknown("No mock response for endpoint"))
    }
    
    // Helper pour définir une réponse mock
    func setResponse<T: Encodable>(for endPoint: APIEndPoint, value: T, wrappedInData: Bool = true) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let data: Data
            if wrappedInData {
                let wrapper = APIContainer(data: value)
                data = try encoder.encode(wrapper)
            } else {
                data = try encoder.encode(value)
            }
            responses[endPoint] = .success(data)
        } catch {
            responses[endPoint] = .failure(.encodingError(error.localizedDescription))
        }
    }
    
    func setError(for endPoint: APIEndPoint, error: APIError) {
        responses[endPoint] = .failure(error)
    }
    
    func reset() {
        responses.removeAll()
        callCount.removeAll()
    }
}

// MARK: - Helper Wrapper (même structure que NetworkClient.APIContainer)

struct APIContainer<T: Codable>: Codable {
    let data: T
}

