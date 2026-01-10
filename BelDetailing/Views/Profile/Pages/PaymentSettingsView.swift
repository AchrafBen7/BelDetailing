//
//  PaymentSettingsView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

import SwiftUI
import StripePaymentSheet
import RswiftResources

struct PaymentSettingsView: View {

    @StateObject private var vm: PaymentSettingsViewModel
    private let engine: Engine
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @Environment(\.dismiss) private var dismiss

    init(engine: Engine) {
        self.engine = engine
        _vm = StateObject(
            wrappedValue: PaymentSettingsViewModel(engine: engine)
        )
    }

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
            Color(R.color.mainBackground.name)
                .ignoresSafeArea()
                .overlay(
                    Color.black
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top),
                    alignment: .top
                )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    
                    VStack(alignment: .leading, spacing: 28) {
                        paymentMethodsSection
                        transactionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }

            if vm.isLoading {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(.circular)
            }

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
                    vm.paymentSheet = nil
                    vm.isPresentingPaymentSheet = false
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
        .task {
            await vm.load()
        }
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
        .sheet(item: $vm.selectedTransaction) { transaction in
            TransactionDetailView(
                transaction: transaction,
                booking: vm.bookingForTransaction(transaction.id),
                engine: engine
            )
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Paiements & versements")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Gérez vos cartes et consultez l'historique")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
        .padding(.bottom, 1)
    }

    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Moyens de paiement")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                NavigationLink {
                    AddPaymentMethodView(engine: engine) {
                        Task { await vm.load() }
                    }
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if !method.isDefault {
                                    Button(role: .destructive) {
                                        Task {
                                            await vm.delete(method: method)
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
            }
        }
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historique des transactions")
                .font(.system(size: 20, weight: .bold))

            if vm.transactions.isEmpty {
                emptyTransactions
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.transactions) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            booking: vm.bookingForTransaction(transaction.id),
                            onTap: {
                                vm.selectedTransaction = transaction
                            }
                        )
                    }
                }
            }
        }
    }

    private var emptyPaymentMethods: some View {
        EmptyStateView(
            title: "Aucun moyen de paiement",
            message: "Ajoutez une carte pour commencer.",
            systemIcon: "creditcard"
        )
    }

    private var emptyTransactions: some View {
        EmptyStateView(
            title: "Aucune transaction",
            message: "Vos transactions apparaîtront ici.",
            systemIcon: "clock.arrow.circlepath"
        )
    }
}

