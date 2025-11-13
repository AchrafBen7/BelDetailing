//
//  BookingStatus+UI.swift
//  BelDetailing
//
//  Created by Achraf Benali on 13/11/2025.
//

import SwiftUI
import RswiftResources

extension BookingStatus {

    /// Titre localisé (via R.swift)
    var localizedTitle: String {
        switch self {
        case .pending:
            return R.string.localizable.bookingStatusPending()
        case .confirmed:
            return R.string.localizable.bookingStatusConfirmed()
        case .declined:
            return R.string.localizable.bookingStatusDeclined()
        case .cancelled:
            return R.string.localizable.bookingStatusCancelled()
        case .completed:
            return R.string.localizable.bookingStatusCompleted()
        }
    }

    /// Couleur du badge selon le statut (UI cohérente)
    var badgeBackground: Color {
        switch self {
        case .pending:
            return Color(R.color.badgeYellow)      // ou ta couleur
        case .confirmed:
            return Color(R.color.badgeGreen)
        case .declined:
            return Color(R.color.badgeRed)
        case .cancelled:
            return Color(R.color.badgeGray)
        case .completed:
            return Color(R.color.badgeBlue)
        }
    }
}
