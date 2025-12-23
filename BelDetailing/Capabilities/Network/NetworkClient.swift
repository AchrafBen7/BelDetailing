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
        URL(string: server.rawValue + endpointMapperClass.path(for: endPoint))
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
                        let decoded = try NetworkClient.defaultDecoder.decode(APIContainer<T>.self, from: data)
                        return .success(decoded.data)
                    } else {
                        let decoded = try NetworkClient.defaultDecoder.decode(T.self, from: data)
                        return .success(decoded)
                    }
                } catch let error {
                    return .failure(.decodingError(decodingError: error))
                }

            } else if httpResponse.statusCode == 401 {
                if !allowAutoRefresh || endPoint == .refresh {
                    StorageManager.shared.clearSession()
                    return .failure(.unauthorized)
                }

                if let newAccess = await Self.refreshAccessToken() {
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
              !refresh.isEmpty else { return nil }

        let client = NetworkClient(server: .prod)
        let response: APIResponse<AuthSession> = await client.call(
            endPoint: .refresh,
            dict: ["refreshToken": refresh],
            allowAutoRefresh: false   // 🔥 pas de boucle ici
        )

        if case let .success(session) = response {
            StorageManager.shared.saveAccessToken(session.accessToken)
            StorageManager.shared.saveRefreshToken(session.refreshToken)
            defaultHeaders["Authorization"] = "Bearer \(session.accessToken)"
            return session.accessToken
        }

        return nil
    }
}

extension NetworkClient {
    func callRaw(
        endPoint: APIEndPoint,
        dict: [String: Any?]? = nil,
        urlDict: [String: Any?]? = nil,
        timeout: TimeInterval = 60
    ) async -> APIResponse<Data> {

        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard var url = url(endPoint: endPoint) else {
            return .failure(.urlError)
        }
        if let urlDict { url = NetworkClient.urlFor(url: url, urlDict: urlDict) }

        var request = URLRequest(url: url)
        request.httpMethod = endpointMapperClass.method(for: endPoint).rawValue
        request.httpBody = dict != nil ? try? JSONSerialization.data(withJSONObject: dict!) : nil
        request.allHTTPHeaderFields = NetworkClient.defaultHeaders
        request.timeoutInterval = timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return .failure(.unknownError)
            }

            NetworkClient.logRequest(request: request, urlResponse: http, data: data)

            if (200...299).contains(http.statusCode) {
                return .success(data)
            } else {
                return .failure(.serverError(statusCode: http.statusCode))
            }
        } catch {
            return .failure(.from(error: error))
        }
    }
}

extension NetworkClient: NetworkClientProtocol {}
