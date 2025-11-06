//
//  NetworkTypes+Helpers.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//


import Foundation

enum Server: String {
  case dev = "http://localhost:8000/"
  case prod = "https://api.beldetail.be/"
}

typealias APIResponse<T: Decodable> = Result<T, APIError>

// MARK: - Data → JSON debug helper
extension Data {
  func mapJSON() -> Any? {
    try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
  }
}

// MARK: - Curl generator (debug)
extension URLRequest {
  public var curlString: String {
    var result = "curl -k "

    if let method = httpMethod {
      result += "-X \(method) \\\n"
    }

    if let headers = allHTTPHeaderFields {
      for (header, value) in headers {
        result += "-H \"\(header): \(value)\" \\\n"
      }
    }

    if let body = httpBody, !body.isEmpty,
       let string = String(data: body, encoding: .utf8),
       !string.isEmpty {
      result += "-d '\(string)' \\\n"
    }

    if let url = url {
      result += url.absoluteString
    }

    return result
  }
}
