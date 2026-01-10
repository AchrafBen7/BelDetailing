//
//  NetworkClient.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

final class NetworkClient {
    // MARK: - Properties
    static var defaultDecoder: JSONDecoder {
        let result = JSONDecoder()
        result.dateDecodingStrategy = .iso8601
        result.keyDecodingStrategy = .convertFromSnakeCase
        return result
    }
    static var defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    let endpointMapperClass: EndpointMapper.Type
    let server: Server

    // Managers globaux (optionnels)
    weak var loadingManager: LoadingOverlayManager?
    weak var downloadProgressManager: DownloadProgressManager?   // ⬅️ AJOUT

    init(
        server: Server,
        endpointMapperClass: EndpointMapper.Type = BelDetailingEndpointMapper.self,
        loadingManager: LoadingOverlayManager? = nil,
        downloadProgressManager: DownloadProgressManager? = nil
    ) {
        self.endpointMapperClass = endpointMapperClass
        self.server = server
        self.loadingManager = loadingManager
        self.downloadProgressManager = downloadProgressManager
    }

    // MARK: - Logging
    static func logRequest(request: URLRequest, urlResponse: HTTPURLResponse, data: Data) {
        print(
      """
      [NETWORK CLIENT]
      \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")
      headers: \(request.allHTTPHeaderFields?.description ?? "[]")
      payload: \(request.httpBody?.mapJSON() ?? "[]")
      curlRequest: \(request.curlString)
      --> Response \(urlResponse.statusCode)
      Response Data: \(data.mapJSON() ?? "[]")
      """
        )
    }
    // MARK: - URL builder with query params
    static func urlFor(url: URL, urlDict: [String: Any?]) -> URL {
        var urlComponents = URLComponents(string: url.absoluteString)

        var items: [URLQueryItem] = []

        for (key, value) in urlDict {
            guard let value else { continue }

            if let str = value as? String, str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }

            if let arr = value as? [String] {
                for value in arr where !value.isEmpty {
                    items.append(URLQueryItem(name: key, value: value))
                }
                continue
            }

            items.append(URLQueryItem(name: key, value: "\(value)"))
        }

        urlComponents?.queryItems = items.isEmpty ? nil : items
        return urlComponents?.url ?? url
    }

    
    func url(endPoint: APIEndPoint) -> URL? {
        let path = endpointMapperClass.path(for: endPoint)
        let fullURL = server.rawValue + path
        print("🔷 [NetworkClient] url() - endpoint: \(endPoint), path: \(path), fullURL: \(fullURL)")
        return URL(string: fullURL)
    }
    
    // MARK: - JSON call (classique)
    func call<T: Decodable>(
        endPoint: APIEndPoint,
        dict: [String: Any?]? = nil,
        urlDict: [String: Any?]? = nil,
        additionalHeaders: [String: String]? = nil,
        timeout: TimeInterval = 60,
        allowAutoRefresh: Bool = true,
        wrappedInData: Bool = false   // ✅ ICI, c'est normal
    ) async -> APIResponse<T> {
        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard var url = url(endPoint: endPoint) else {
            return .failure(.urlError)
        }
        if let urlDict {
            url = NetworkClient.urlFor(url: url, urlDict: urlDict)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpointMapperClass.method(for: endPoint).rawValue
        request.httpBody = dict != nil ? try? JSONSerialization.data(withJSONObject: dict ?? [:]) : nil
        request.timeoutInterval = timeout
        request.allHTTPHeaderFields = NetworkClient.defaultHeaders.merging(additionalHeaders ?? [:]) { _, new in new }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknownError)
            }
            NetworkClient.logRequest(request: request, urlResponse: httpResponse, data: data)

            if (200...299).contains(httpResponse.statusCode) {
                do {
                    if wrappedInData {
                        // Log raw JSON for debugging
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("📦 [NetworkClient] Raw JSON response (first 500 chars): \(String(jsonString.prefix(500)))")
                        }
                        
                        let decoded = try NetworkClient.defaultDecoder.decode(APIContainer<T>.self, from: data)
                        return .success(decoded.data)
                    } else {
                        let decoded = try NetworkClient.defaultDecoder.decode(T.self, from: data)
                        return .success(decoded)
                    }
                } catch let error {
                    // Log detailed decoding error
                    if let decodingError = error as? DecodingError {
                        print("❌ [NetworkClient] Decoding error details:")
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("   Type mismatch: expected \(type), path: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("   Value not found: \(type), path: \(context.codingPath)")
                        case .keyNotFound(let key, let context):
                            print("   Key not found: \(key), path: \(context.codingPath)")
                        case .dataCorrupted(let context):
                            print("   Data corrupted: \(context)")
                        @unknown default:
                            print("   Unknown decoding error: \(decodingError)")
                        }
                    }
                    return .failure(.decodingError(decodingError: error))
                }

            } else if httpResponse.statusCode == 401 {
                if !allowAutoRefresh || endPoint == .refresh {
                    print("🔒 [NetworkClient] 401 Unauthorized - Auto refresh disabled or refresh endpoint")
                    StorageManager.shared.clearSession()
                    return .failure(.unauthorized)
                }

                print("🔄 [NetworkClient] 401 Unauthorized - Attempting token refresh...")
                if let newAccess = await Self.refreshAccessToken() {
                    print("✅ [NetworkClient] Token refreshed successfully, retrying request...")
                    NetworkClient.defaultHeaders["Authorization"] = "Bearer \(newAccess)"
                    return await self.call(
                        endPoint: endPoint,
                        dict: dict,
                        urlDict: urlDict,
                        additionalHeaders: additionalHeaders,
                        timeout: timeout,
                        allowAutoRefresh: false
                    )
                }

                print("❌ [NetworkClient] Token refresh failed, clearing session")
                StorageManager.shared.clearSession()
                return .failure(.unauthorized)
            }

            return .failure(.serverError(statusCode: httpResponse.statusCode))

        } catch let error {
            return .failure(.from(error: error))
        }
    }


    struct APIContainer<T: Decodable>: Decodable {
        let data: T
    }
    
    // MARK: - File Upload (multipart/form-data)
    func call<T: Decodable>(
        endPoint: APIEndPoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        timeout: TimeInterval = 60
    ) async -> APIResponse<T> {
        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard let url = url(endPoint: endPoint) else {
            return .failure(.urlError)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpointMapperClass.method(for: endPoint).rawValue

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let auth = NetworkClient.defaultHeaders["Authorization"] {
            request.setValue(auth, forHTTPHeaderField: "Authorization")
        }

        request.timeoutInterval = timeout

        // Corps multipart
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("📦RAW JSON RESPONSE:\n", String(data: data, encoding: .utf8) ?? "⛔️ (non-string)")
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknownError)
            }
            NetworkClient.logRequest(request: request, urlResponse: httpResponse, data: data)

            if (200...299).contains(httpResponse.statusCode) {
                do {
                    let decoded = try NetworkClient.defaultDecoder.decode(T.self, from: data)
                    return .success(decoded)
                } catch let error {
                    return .failure(.decodingError(decodingError: error))
                }
            } else if httpResponse.statusCode == 401 {
                // Try to refresh token for file uploads too
                print("🔄 [NetworkClient] 401 Unauthorized on file upload - Attempting token refresh...")
                if let newAccess = await Self.refreshAccessToken() {
                    print("✅ [NetworkClient] Token refreshed, retrying file upload...")
                    NetworkClient.defaultHeaders["Authorization"] = "Bearer \(newAccess)"
                    // Retry the request with new token
                    return await self.call(
                        endPoint: endPoint,
                        fileData: fileData,
                        fileName: fileName,
                        mimeType: mimeType,
                        timeout: timeout
                    )
                }
                print("❌ [NetworkClient] Token refresh failed for file upload")
                StorageManager.shared.clearSession()
                return .failure(.unauthorized)
            }

            return .failure(.serverError(statusCode: httpResponse.statusCode))

        } catch let error {
            return .failure(.from(error: error))
        }
    }
}

extension NetworkClient {
    static func refreshAccessToken() async -> String? {
        guard let refresh = StorageManager.shared.getRefreshToken(),
              !refresh.isEmpty else {
            print("❌ [NetworkClient] No refresh token available")
            return nil
        }

        print("🔄 [NetworkClient] Refreshing access token...")
        let client = NetworkClient(server: .prod)
        let response: APIResponse<AuthSession> = await client.call(
            endPoint: .refresh,
            dict: ["refreshToken": refresh],
            allowAutoRefresh: false   // 🔥 pas de boucle ici
        )

        if case let .success(session) = response {
            print("✅ [NetworkClient] Token refresh successful")
            StorageManager.shared.saveAccessToken(session.accessToken)
            StorageManager.shared.saveRefreshToken(session.refreshToken)
            defaultHeaders["Authorization"] = "Bearer \(session.accessToken)"
            return session.accessToken
        }

        print("❌ [NetworkClient] Token refresh failed: \(response)")
        return nil
    }
}

extension NetworkClient {
    func callRaw(
        endPoint: APIEndPoint,
        dict: [String: Any?]? = nil,
        urlDict: [String: Any?]? = nil,
        timeout: TimeInterval = 60,
        allowAutoRefresh: Bool = true
    ) async -> APIResponse<Data> {
        print("🔷 [NetworkClient] callRaw START - endpoint: \(endPoint)")
        defer { print("🔷 [NetworkClient] callRaw END") }

        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard var url = url(endPoint: endPoint) else {
            print("❌ [NetworkClient] callRaw - URL error")
            return .failure(.urlError)
        }
        if let urlDict { url = NetworkClient.urlFor(url: url, urlDict: urlDict) }
        print("🔷 [NetworkClient] callRaw - URL: \(url.absoluteString)")

        // Ajouter le token d'authentification s'il est disponible
        var headers = NetworkClient.defaultHeaders
        if let token = StorageManager.shared.getAccessToken(), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
            print("🔷 [NetworkClient] callRaw - Token added to headers (length: \(token.count))")
        } else {
            print("⚠️ [NetworkClient] callRaw - No token available")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpointMapperClass.method(for: endPoint).rawValue
        request.httpBody = dict != nil ? try? JSONSerialization.data(withJSONObject: dict!) : nil
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = timeout

        print("🔷 [NetworkClient] callRaw - Making request: \(request.httpMethod ?? "?") \(url.absoluteString)")

        do {
            print("🔷 [NetworkClient] callRaw - Awaiting URLSession.data...")
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🔷 [NetworkClient] callRaw - URLSession.data returned, data size: \(data.count) bytes")
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ [NetworkClient] callRaw - Response is not HTTPURLResponse")
                return .failure(.unknownError)
            }

            print("🔷 [NetworkClient] callRaw - HTTP Status: \(http.statusCode)")
            NetworkClient.logRequest(request: request, urlResponse: http, data: data)

            if (200...299).contains(http.statusCode) {
                print("✅ [NetworkClient] callRaw - Success (status \(http.statusCode))")
                return .success(data)
            } else if http.statusCode == 401 && allowAutoRefresh && endPoint != .refresh {
                // Essayer de rafraîchir le token
                print("🔄 [NetworkClient] 401 Unauthorized in callRaw - Attempting token refresh...")
                if let newAccess = await Self.refreshAccessToken() {
                    print("✅ [NetworkClient] Token refreshed, retrying callRaw...")
                    NetworkClient.defaultHeaders["Authorization"] = "Bearer \(newAccess)"
                    // Retry avec le nouveau token
                    return await self.callRaw(
                        endPoint: endPoint,
                        dict: dict,
                        urlDict: urlDict,
                        timeout: timeout,
                        allowAutoRefresh: false
                    )
                }
                print("❌ [NetworkClient] Token refresh failed in callRaw")
                StorageManager.shared.clearSession()
                return .failure(.unauthorized)
            } else {
                print("❌ [NetworkClient] callRaw - Server error (status \(http.statusCode))")
                return .failure(.serverError(statusCode: http.statusCode))
            }
        } catch {
            print("❌ [NetworkClient] callRaw - Exception: \(error.localizedDescription)")
            return .failure(.from(error: error))
        }
    }
}

extension NetworkClient: NetworkClientProtocol {}
