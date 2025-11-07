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
    "content-type": "application/json",
    "Accept": "application/json"
  ]
  let endpointMapperClass: EndpointMapper.Type
  let server: Server
  init(server: Server, endpointMapperClass: EndpointMapper.Type = BelDetailingEndpointMapper.self) {
    self.endpointMapperClass = endpointMapperClass
    self.server = server
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
    let queryItems = urlDict.flatMap { (key, value) -> [URLQueryItem] in
      if let value = value as? [String] {
        return value.map { URLQueryItem(name: key, value: $0) }
      }
      return [URLQueryItem(name: key, value: "\(value ?? "")")]
    }
    urlComponents?.queryItems = queryItems
    return urlComponents?.url ?? url
  }

  func url(endPoint: APIEndPoint) -> URL? {
    URL(string: server.rawValue + endpointMapperClass.path(for: endPoint))
  }

  // MARK: - Async call
  func call<T: Decodable>(endPoint: APIEndPoint,
                          dict: [String: Any?]? = nil,
                          urlDict: [String: Any?]? = nil,
                          additionalHeaders: [String: String]? = nil,
                          timeout: TimeInterval = 60) async -> APIResponse<T> {
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
    request.allHTTPHeaderFields = NetworkClient.defaultHeaders.merging(additionalHeaders ?? [:], uniquingKeysWith: { _, new in new })

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
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
