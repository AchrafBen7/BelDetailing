//
//  ServiceCategory.swift
//  BelDetailing
//

import Foundation
import RswiftResources

// Raw values aligned to backend tokens
enum ServiceCategory: String, Codable, CaseIterable, Hashable {
  case interiorDetailing = "interior"
  case exteriorDetailing = "exterior"
  case carCleaning       = "full"             // backend sends "full" (full detailing)

  case carPolishing      = "polishing"
  case ceramicCoating    = "ceramic"
  case paintCorrection   = "paint_correction"
  case headlightRestoration = "headlight"
  case engineBay         = "engine_bay"
  case wheelsTires       = "wheels_tires"
  case waxSealant        = "wax_sealant"

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
