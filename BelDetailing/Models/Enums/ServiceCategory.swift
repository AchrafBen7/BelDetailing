//
//  ServiceCategory.swift
//  BelDetailing
//

import Foundation
import RswiftResources

enum ServiceCategory: String, Codable, CaseIterable, Hashable {
  case carCleaning
  case carPolishing
  case interiorDetailing
  case exteriorDetailing
  case ceramicCoating
  case paintCorrection
  case headlightRestoration
  case engineBay
  case wheelsTires
  case waxSealant

  /// 🔁 Réutilise les localisables des filtres (mêmes libellés)
  var localizedTitle: String {
    switch self {
    case .carCleaning:          return R.string.localizable.filterCarCleaning()
    case .carPolishing:         return R.string.localizable.filterPolishing()
    case .interiorDetailing:    return R.string.localizable.filterInterior()
    case .exteriorDetailing:    return R.string.localizable.filterExterior()
    case .ceramicCoating:       return R.string.localizable.filterCeramic()
    case .paintCorrection:      return R.string.localizable.filterPaintCorrection()
    case .headlightRestoration: return R.string.localizable.filterHeadlight()
    case .engineBay:            return R.string.localizable.filterEngineBay()
    case .wheelsTires:          return R.string.localizable.filterWheelsTires()
    case .waxSealant:           return R.string.localizable.filterWaxSealant()
    }
  }
}
