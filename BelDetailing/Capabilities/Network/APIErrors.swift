//
//  APIErrors.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation
import RswiftResources

public enum APIError: Error, LocalizedError {
  case urlError
  case noNetwork
  case decodingError(decodingError: Error)
  case serverError(statusCode: Int)
  case unauthorized
  case unknownError
  case other(error: Error?)
  
  public static func from(error: Error?) -> APIError {
    if let error = error as? APIError {
      return error
    }
    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
      return .noNetwork
    }
    return .other(error: error)
  }
  
  public var localizedDescription: String? {
    switch self {
    case .urlError:
        return R.string.localizable.apiErrorUrlError()
    case .noNetwork:
      return R.string.localizable.apiErrorNoNetwork()
    case .decodingError(let decodingError):
      return R.string.localizable.apiErrorDecodingError(decodingError.localizedDescription)
    case .serverError(let statusCode):
      return R.string.localizable.apiErrorServerError("\(statusCode)")
    case .unauthorized:
      return R.string.localizable.apiErrorUnauthorized()
    case .unknownError:
      return R.string.localizable.apiErrorUnknownError()
    case .other(let error):
      return R.string.localizable.apiErrorOther(error?.localizedDescription ?? "")
    }
  }
}
