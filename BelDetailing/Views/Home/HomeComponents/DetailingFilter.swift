//
//  DetailingFilter.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//
import Foundation
import RswiftResources

enum DetailingFilter: CaseIterable, Identifiable, Equatable {
  case all
  case polishing
  case ceramic
  case interior
  case exterior
  case paintCorrection
  case headlight
  case engineBay
  case wheelsTires
  case waxSealant

  var id: String { key }

  private var key: String {
    switch self {
    case .all:             return "filter_all"
    case .polishing:       return "filter_polishing"
    case .ceramic:         return "filter_ceramic"
    case .interior:        return "filter_interior"
    case .exterior:        return "filter_exterior"
    case .paintCorrection: return "filter_paint_correction"
    case .headlight:       return "filter_headlight"
    case .engineBay:       return "filter_engine_bay"
    case .wheelsTires:     return "filter_wheels_tires"
    case .waxSealant:      return "filter_wax_sealant"
    }
  }

  var title: String {
    switch self {
    case .all:
        return R.string.localizable.filterAll()
    case .polishing:       return R.string.localizable.filterPolishing()
    case .ceramic:         return R.string.localizable.filterCeramic()
    case .interior:        return R.string.localizable.filterInterior()
    case .exterior:        return R.string.localizable.filterExterior()
    case .paintCorrection: return R.string.localizable.filterPaintCorrection()
    case .headlight:       return R.string.localizable.filterHeadlight()
    case .engineBay:       return R.string.localizable.filterEngineBay()
    case .wheelsTires:     return R.string.localizable.filterWheelsTires()
    case .waxSealant:      return R.string.localizable.filterWaxSealant()
    }
  }
}
extension DetailingFilter {
  /// Mapping entre le filtre et les `ServiceCategory` correspondants
  var relatedCategories: [ServiceCategory] {
    switch self {
    case .all:             return ServiceCategory.allCases
    case .polishing:       return [.carPolishing, .paintCorrection]
    case .ceramic:         return [.ceramicCoating, .waxSealant]
    case .interior:        return [.interiorDetailing]
    case .exterior:        return [.exteriorDetailing, .carCleaning]
    case .paintCorrection: return [.paintCorrection]
    case .headlight:       return [.headlightRestoration]
    case .engineBay:       return [.engineBay]
    case .wheelsTires:     return [.wheelsTires]
    case .waxSealant:      return [.waxSealant]
    }
  }
}
