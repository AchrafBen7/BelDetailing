//
//  DownloadProgressManager.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/12/2025.
//

import Foundation
import Combine

@MainActor
final class DownloadProgressManager: ObservableObject {
    // true si on suit une progression, sinon fallback indéterminé
    @Published var isActive: Bool = false
    // true si la taille attendue est inconnue (on affiche un spinner)
    @Published var isIndeterminate: Bool = true
    // 0.0 ... 1.0 si déterminé
    @Published var progress: Double = 0.0

    func begin(indeterminate: Bool = true) {
        isActive = true
        isIndeterminate = indeterminate
        if indeterminate {
            progress = 0.0
        }
    }

    func updateProgress(received: Int64, expected: Int64) {
        guard expected > 0 else {
            isIndeterminate = true
            return
        }
        isIndeterminate = false
        progress = min(1.0, max(0.0, Double(received) / Double(expected)))
    }

    func end() {
        isActive = false
        isIndeterminate = true
        progress = 0.0
    }
}
