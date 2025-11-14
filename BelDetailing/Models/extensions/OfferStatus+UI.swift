//
//  OfferStatus+UI.swift
//  BelDetailing
//
//  Created by Achraf Benali on 14/11/2025.
//

import SwiftUI
import RswiftResources

extension OfferStatus {

    var localizedTitle: String {
        switch self {
        case .open:
            return R.string.localizable.offerStatusOpen()
        case .closed:
            return R.string.localizable.offerStatusClosed()
        case .archived:
            return R.string.localizable.offerStatusArchived()
        }
    }

    var badgeBackground: Color {
        switch self {
        case .open:
            return Color(R.color.badgeGreen)    // ouvert
        case .closed:
            return Color(R.color.badgeYellow)   // clôturé / en review
        case .archived:
            return Color(R.color.badgeGray)     // archivé
        }
    }
}

extension OfferType {
    var localizedTitle: String {
        switch self {
        case .oneTime:
            return R.string.localizable.offerTypeOneTime()
        case .recurring:
            return R.string.localizable.offerTypeRecurring()
        case .longTerm:
            return R.string.localizable.offerTypeLongTerm()
        }
    }
}
enum OfferStatusFilter: CaseIterable {
    case all
    case open
    case closed
    case archived

    var status: OfferStatus? {
        switch self {
        case .all:      return nil
        case .open:     return .open
        case .closed:   return .closed
        case .archived: return .archived
        }
    }

    var title: String {
        switch self {
        case .all:
            return R.string.localizable.filterAll()
        case .open:
            return R.string.localizable.offerStatusOpen()
        case .closed:
            return R.string.localizable.offerStatusClosed()
        case .archived:
            return R.string.localizable.offerStatusArchived()
        }
    }
}
