import SwiftUI

struct TransactionRow: View {
    let transaction: PaymentTransaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(transaction.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(formattedAmount)
                .font(.system(size: 15, weight: .bold))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
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
        // signe simple: refund négatif, sinon positif
        let sign = transaction.type.lowercased() == "refund" ? "-" : "+"
        let amountStr = String(format: "%.2f", transaction.amount)
        return "\(sign)\(amountStr) \(transaction.currency.uppercased())"
    }
}
