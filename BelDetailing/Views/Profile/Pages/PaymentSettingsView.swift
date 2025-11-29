//
//  PaymentSettingsView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

//  PaymentSettingsView.swift


import SwiftUI
import RswiftResources

struct PaymentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: PaymentSettingsViewModel
    
    init(engine: Engine) {
        _vm = StateObject(wrappedValue: PaymentSettingsViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Back
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                    }
                    
                    // MARK: - Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.paymentsTitle())
                            .font(.system(size: 28, weight: .bold))
                        Text(R.string.localizable.paymentsSubtitle())
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                    
                    // MARK: - Section: Payment Methods
                    HStack {
                        Text(R.string.localizable.paymentsMethodsTitle())
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Button {
                            // plus tard: ajouter une carte
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text(R.string.localizable.paymentsAddButton())
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(vm.paymentMethods) { method in
                            PaymentMethodRow(
                                method: method,
                                onSetDefault: { vm.setDefault(method) },
                                onDelete: { vm.delete(method) }
                            )
                        }
                    }
                    
                    // MARK: - Section: Transactions
                    Text(R.string.localizable.paymentsHistoryTitle())
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 8)
                    
                    PaymentTransactionsCard(transactions: vm.transactions)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 8)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - Subviews

private struct PaymentMethodRow: View {
    let method: PaymentMethod
    let onSetDefault: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(width: 52, height: 52)
                Image(systemName: "creditcard")
                    .font(.system(size: 22, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(method.brand) •••• \(method.last4)")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(R.string.localizable.paymentsExpiresPrefix()) \(String(format: "%02d", method.expMonth))/\(String(method.expYear % 100))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if method.isDefault {
                Text(R.string.localizable.paymentsDefaultBadge())
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

private struct PaymentTransactionsCard: View {
    let transactions: [PaymentTransaction]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(transactions, id: \.id) { tx in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tx.title)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(DateFormatters.shortDate.string(from: tx.date))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(amountText(tx.amount))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tx.amount >= 0 ? .green : .black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if tx.id != transactions.last?.id {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func amountText(_ amount: Double) -> String {
        let sign = amount >= 0 ? "+" : ""
        return "\(sign)\(Int(amount))€"
    }
}
