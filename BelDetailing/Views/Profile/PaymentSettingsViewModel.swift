//
//  PaymentSettingsViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

import SwiftUI
import RswiftResources
import Combine

@MainActor
final class PaymentSettingsViewModel: ObservableObject {
    private let engine: Engine
    
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var transactions: [PaymentTransaction] = []
    
    init(engine: Engine) {
        self.engine = engine
        loadMockData()   // pour l’instant: mock → plus tard Stripe / backend
    }
    
    private func loadMockData() {
        paymentMethods = PaymentMethod.sampleValues
        transactions = PaymentTransaction.sampleValues
    }
    
    func setDefault(_ method: PaymentMethod) {
        paymentMethods = paymentMethods.map { pm in
            PaymentMethod(
                id: pm.id,
                brand: pm.brand,
                last4: pm.last4,
                expMonth: pm.expMonth,
                expYear: pm.expYear,
                isDefault: pm.id == method.id
            )
        }
    }
    
    func delete(_ method: PaymentMethod) {
        paymentMethods.removeAll { $0.id == method.id }
    }
}
