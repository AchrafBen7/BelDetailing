//
//  TransactionRow.swift
//  BelDetailing
//
//  Created by Achraf Benali on 22/12/2025.
//

import SwiftUI
import UIKit
import StripePaymentSheet

struct TransactionRow: View {
    let transaction: PaymentTransaction
    let booking: Booking?
    let onTap: (() -> Void)?
    
    init(transaction: PaymentTransaction, booking: Booking? = nil, onTap: (() -> Void)? = nil) {
        self.transaction = transaction
        self.booking = booking
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(transaction.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let booking = booking {
                        Text(booking.displayServiceName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedAmount)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(amountColor)
                    
                    if transaction.status.lowercased() != "succeeded" && transaction.status.lowercased() != "paid" {
                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch transaction.type.lowercased() {
        case "payment": return "Paiement"
        case "refund": return "Remboursement"
        case "payout": return "Versement"
        default: return "Transaction"
        }
    }

    private var icon: String {
        switch transaction.type.lowercased() {
        case "payment": return "creditcard"
        case "refund": return "arrow.uturn.left"
        case "payout": return "banknote"
        default: return "doc"
        }
    }

    private var color: Color {
        transaction.type.lowercased() == "refund" ? .red : .green
    }

    private var formattedAmount: String {
        let sign = transaction.type.lowercased() == "refund" ? "-" : "+"
        let amountStr = String(format: "%.2f", transaction.amount)
        return "\(sign)\(amountStr) \(transaction.currency.uppercased())"
    }
    
    private var amountColor: Color {
        transaction.type.lowercased() == "refund" ? .red : .green
    }
    
    private var statusText: String {
        switch transaction.status.lowercased() {
        case "succeeded", "paid": return "Réussi"
        case "pending": return "En attente"
        case "failed": return "Échoué"
        case "refunded": return "Remboursé"
        case "processing": return "En cours"
        default: return transaction.status.capitalized
        }
    }
    
    private var statusColor: Color {
        switch transaction.status.lowercased() {
        case "succeeded", "paid": return .green
        case "pending", "processing": return .orange
        case "failed": return .red
        case "refunded": return .blue
        default: return .gray
        }
    }
}

// MARK: - PaymentSheetHost Component

struct PaymentSheetHost: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let paymentSheet: PaymentSheet
    let onResult: (PaymentSheetResult) -> Void
    
    func makeUIViewController(context: Context) -> PaymentSheetHostViewController {
        PaymentSheetHostViewController()
    }
    
    func updateUIViewController(_ uiViewController: PaymentSheetHostViewController, context: Context) {
        if isPresented && !uiViewController.hasPresented {
            DispatchQueue.main.async {
                uiViewController.hasPresented = true
                paymentSheet.present(from: uiViewController) { result in
                    uiViewController.hasPresented = false
                    isPresented = false
                    onResult(result)
                }
            }
        } else if !isPresented {
            uiViewController.hasPresented = false
        }
    }
}

class PaymentSheetHostViewController: UIViewController {
    var hasPresented = false
}
