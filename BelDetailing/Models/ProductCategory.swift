//
//  ProductCategory.swift
//  BelDetailing
//

import Foundation

enum ProductCategory: String, CaseIterable, Codable, Hashable {
    case interior
    case exterior
    case accessory

    var localizedTitle: String {
        switch self {
        case .interior: return "Intérieur"
        case .exterior: return "Extérieur"
        case .accessory: return "Accessoires"
        }
    }
}
