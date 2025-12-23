//
//  PaymentSettingsView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

//
//  PaymentSettingsView.swift
//  BelDetailing
//

import SwiftUI
import StripePaymentSheet

struct PaymentSettingsView: View {

    @StateObject private var vm: PaymentSettingsViewModel
    private let engine: Engine

    init(engine: Engine) {
        self.engine = engine
        _vm = StateObject(
            wrappedValue: PaymentSettingsViewModel(engine: engine)
        )
    }

    // ✅ Binding SAFE : la sheet ne peut s’ouvrir QUE si elle existe
    private var isShowingPaymentSheet: Binding<Bool> {
        Binding(
            get: {
                vm.isPresentingPaymentSheet && vm.paymentSheet != nil
            },
            set: { newValue in
                if !newValue {
                    vm.isPresentingPaymentSheet = false
                    vm.paymentSheet = nil
                }
            }
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Paiements & versements")
                            .font(.system(size: 28, weight: .bold))

                        Text("Gérez vos cartes et consultez l’historique")
                            .foregroundColor(.secondary)
                    }

                    // MARK: - Sections
                    paymentMethodsSection
                    transactionsSection
                }
                .padding(20)
            }

            // MARK: - Loading overlay
            if vm.isLoading {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(.circular)
            }

            // ✅ LA CLÉ : Stripe PaymentSheet attachée à une VRAIE VIEW
            if let sheet = vm.paymentSheet {
                PaymentSheetHost(
                    isPresented: isShowingPaymentSheet,
                    paymentSheet: sheet
                ) { result in
                    switch result {
                    case .completed:
                        Task { await vm.load() }

                    case .failed(let error):
                        vm.errorText = error.localizedDescription

                    case .canceled:
                        break
                    }

                    // Nettoyage
                    vm.paymentSheet = nil
                    vm.isPresentingPaymentSheet = false
                }
            }
        }
        .task {
            await vm.load()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Erreur",
            isPresented: Binding(
                get: { vm.errorText != nil },
                set: { if !$0 { vm.errorText = nil } }
            )
        ) {
            Button("OK") { vm.errorText = nil }
        } message: {
            Text(vm.errorText ?? "")
        }
    }

    // MARK: - Payment Methods Section
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Moyens de paiement")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Button {
                    Task { await vm.addPaymentMethod() }
                } label: {
                    Label("Ajouter", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(vm.isLoading)
            }

            if vm.paymentMethods.isEmpty {
                emptyPaymentMethods
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.paymentMethods) { method in
                        PaymentMethodCard(method: method)
                    }
                }
            }
        }
    }

    // MARK: - Transactions Section
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Historique des transactions")
                .font(.system(size: 20, weight: .bold))

            if vm.transactions.isEmpty {
                emptyTransactions
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }

    // MARK: - Empty states
    private var emptyPaymentMethods: some View {
        VStack(spacing: 10) {
            Image(systemName: "creditcard")
                .font(.system(size: 32))
                .foregroundColor(.gray)

            Text("Aucune carte enregistrée")
                .font(.system(size: 15, weight: .medium))

            Text("Ajoutez une carte pour payer rapidement vos réservations.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var emptyTransactions: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 32))
                .foregroundColor(.gray)

            Text("Aucune transaction")
                .font(.system(size: 15, weight: .medium))

            Text("Vos paiements et remboursements apparaîtront ici.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

private struct PaymentSheetHost: View {
    @Binding var isPresented: Bool
    let paymentSheet: PaymentSheet
    let onResult: (PaymentSheetResult) -> Void

    var body: some View {
        Color.clear
            .paymentSheet(
                isPresented: $isPresented,
                paymentSheet: paymentSheet,
                onCompletion: onResult
            )
    }
}
