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
    if let nsError = error as NSError? {
      if nsError.code == NSURLErrorNotConnectedToInternet {
        return .noNetwork
      }
      // ✅ Ignorer les erreurs "cancelled" (code -999) - ce ne sont pas de vraies erreurs
      // Cela arrive quand une requête est annulée par une nouvelle requête ou un task SwiftUI
      if nsError.code == NSURLErrorCancelled {
        // Retourner une erreur spéciale qu'on peut ignorer
        return .other(error: error)
      }
    }
    return .other(error: error)
  }
  
  /// Vérifie si l'erreur est une annulation (pas une vraie erreur réseau)
  public var isCancellation: Bool {
    if case .other(let error) = self,
       let nsError = error as NSError?,
       nsError.code == NSURLErrorCancelled {
      return true
    }
    return false
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
