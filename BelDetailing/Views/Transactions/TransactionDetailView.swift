//
//  TransactionDetailView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct TransactionDetailView: View {
    let transaction: PaymentTransaction
    let booking: Booking?
    let engine: Engine
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TransactionDetailViewModel
    @State private var showRefundConfirmation = false
    @State private var showRefundAlert = false
    @State private var refundAlertMessage = ""
    
    init(transaction: PaymentTransaction, booking: Booking?, engine: Engine) {
        self.transaction = transaction
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: TransactionDetailViewModel(transaction: transaction, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header avec montant
                    transactionHeader
                    
                    // Détails
                    transactionDetails
                    
                    // Booking associée (si disponible)
                    if let booking = booking {
                        bookingSection(booking: booking)
                    }
                    
                    // Actions (refund si applicable)
                    if viewModel.canRefund {
                        refundSection
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(R.string.localizable.transactionDetailTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(R.string.localizable.commonClose()) {
                        dismiss()
                    }
                }
            }
            .alert(R.string.localizable.transactionRefundConfirmTitle(), isPresented: $showRefundConfirmation) {
                Button(R.string.localizable.commonCancel(), role: .cancel) {}
                Button(R.string.localizable.transactionRefundConfirmButton(), role: .destructive) {
                    Task {
                        await viewModel.requestRefund()
                        if let error = viewModel.errorMessage {
                            refundAlertMessage = error
                            showRefundAlert = true
                        } else {
                            refundAlertMessage = R.string.localizable.transactionRefundSuccess()
                            showRefundAlert = true
                        }
                    }
                }
            } message: {
                Text(R.string.localizable.transactionRefundConfirmMessage())
            }
            .alert(R.string.localizable.transactionRefundTitle(), isPresented: $showRefundAlert) {
                Button(R.string.localizable.commonOk()) {
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            } message: {
                Text(refundAlertMessage)
            }
        }
    }
    
    // MARK: - Transaction Header
    private var transactionHeader: some View {
        VStack(spacing: 16) {
            // Icône
            Image(systemName: viewModel.icon)
                .font(.system(size: 48))
                .foregroundColor(viewModel.iconColor)
                .frame(width: 100, height: 100)
                .background(viewModel.iconColor.opacity(0.1))
                .clipShape(Circle())
            
            // Montant
            Text(viewModel.formattedAmount)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(viewModel.amountColor)
            
            // Statut
            Text(viewModel.statusText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.statusColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(viewModel.statusColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Transaction Details
    private var transactionDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.transactionDetailInformation())
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 8)
            
            DetailRow(
                label: R.string.localizable.transactionDetailType(),
                value: viewModel.typeText
            )
            DetailRow(
                label: R.string.localizable.transactionDetailDate(),
                value: viewModel.formattedDate
            )
            DetailRow(
                label: R.string.localizable.transactionDetailStatus(),
                value: viewModel.statusText
            )
            DetailRow(
                label: R.string.localizable.transactionDetailId(),
                value: transaction.id
            )
            
            if let paymentIntentId = viewModel.paymentIntentId {
                DetailRow(
                    label: R.string.localizable.transactionDetailPaymentIntent(),
                    value: paymentIntentId
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Booking Section
    private func bookingSection(booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.transactionDetailAssociatedBooking())
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 8)
            
            HStack(spacing: 12) {
                if let urlString = booking.imageURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.displayServiceName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(booking.displayProviderName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("\(booking.date) • \(booking.displayStartTime)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Refund Section
    private var refundSection: some View {
        VStack(spacing: 12) {
            Button {
                showRefundConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.uturn.left")
                    Text(R.string.localizable.transactionRefundRequest())
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isProcessingRefund)
            
            if viewModel.isProcessingRefund {
                ProgressView()
                    .padding(.top, 8)
            }
            
            Text(R.string.localizable.transactionRefundProcessingTime())
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Detail Row Component
private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}


