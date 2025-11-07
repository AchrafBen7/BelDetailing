//
//  CompanyType.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//


import Foundation
import RswiftResources

/// Types d’entreprises pouvant publier des offres.
/// Les noms sont localisés via R.swift pour éviter tout hardcode.
enum CompanyType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case garage
    case leasing
    case fleet
    case carDealer
    case carWash
    case transport
    case construction
    case municipality
    case logistics
    case other

    /// Nom localisé (R.swift → Localizable.xcstrings)
    var localizedName: String {
        switch self {
        case .garage:        return R.string.localizable.companyTypeGarage()
        case .leasing:       return R.string.localizable.companyTypeLeasing()
        case .fleet:         return R.string.localizable.companyTypeFleet()
        case .carDealer:     return R.string.localizable.companyTypeCarDealer()
        case .carWash:       return R.string.localizable.companyTypeCarWash()
        case .transport:     return R.string.localizable.companyTypeTransport()
        case .construction:  return R.string.localizable.companyTypeConstruction()
        case .municipality:  return R.string.localizable.companyTypeMunicipality()
        case .logistics:     return R.string.localizable.companyTypeLogistics()
        case .other:         return R.string.localizable.companyTypeOther()
        }
    }
}
