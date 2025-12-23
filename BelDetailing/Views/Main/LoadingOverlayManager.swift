//
//  LoadingOverlayManager.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/12/2025.
//

import SwiftUI
import Combine

@MainActor
final class LoadingOverlayManager: ObservableObject {

    @Published private(set) var isLoading: Bool = false

    private var counter: Int = 0

    func begin() {
        counter += 1
        isLoading = true
    }

    func end() {
        counter = max(counter - 1, 0)
        if counter == 0 {
            isLoading = false
        }
    }
}
