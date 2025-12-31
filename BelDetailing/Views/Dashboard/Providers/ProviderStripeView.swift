//
//  ProviderStripeView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import SafariServices
import Combine

struct ProviderStripeView: View {
    @StateObject private var viewModel: ProviderStripeViewModel
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: ProviderStripeViewModel(engine: engine))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Account Status
                accountStatusCard
                
                // Balance Summary
                balanceSummaryCard
                
                // Payouts History
                payoutsHistorySection
                
                // Actions
                actionsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: .constant(viewModel.safariURL != nil), onDismiss: { viewModel.safariURL = nil }) {
            if let url = viewModel.safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Account Status Card
    private var accountStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.stripeAccountStatus())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if let status = viewModel.accountStatus {
                VStack(spacing: 12) {
                    statusRow(
                        label: R.string.localizable.stripeChargesEnabled(),
                        value: status.chargesEnabled ? R.string.localizable.commonYes() : R.string.localizable.commonNo(),
                        isEnabled: status.chargesEnabled
                    )
                    
                    statusRow(
                        label: R.string.localizable.stripePayoutsEnabled(),
                        value: status.payoutsEnabled ? R.string.localizable.commonYes() : R.string.localizable.commonNo(),
                        isEnabled: status.payoutsEnabled
                    )
                    
                    if !status.requirements.currentlyDue.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(R.string.localizable.stripeRequirementsPending())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                            
                            ForEach(status.requirements.currentlyDue, id: \.self) { requirement in
                                Text("• \(requirement)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            } else {
                Text(R.string.localizable.stripeNoAccount())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func statusRow(label: String, value: String, isEnabled: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(isEnabled ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    // MARK: - Balance Summary Card
    private var balanceSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.stripeBalance())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if let summary = viewModel.payoutsSummary {
                VStack(spacing: 16) {
                    // Available Balance
                    balanceRow(
                        label: R.string.localizable.stripeAvailable(),
                        amount: summary.available.first?.amount ?? 0,
                        currency: summary.available.first?.currency ?? "EUR"
                    )
                    
                    Divider()
                    
                    // Pending Balance
                    balanceRow(
                        label: R.string.localizable.stripePending(),
                        amount: summary.pending.first?.amount ?? 0,
                        currency: summary.pending.first?.currency ?? "EUR"
                    )
                }
            } else {
                Text(R.string.localizable.stripeNoBalanceData())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func balanceRow(label: String, amount: Int, currency: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(formatAmount(amount, currency: currency))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    // MARK: - Payouts History Section
    private var payoutsHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.stripePayoutsHistory())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if let payouts = viewModel.payoutsSummary?.payouts, !payouts.isEmpty {
                VStack(spacing: 12) {
                    ForEach(payouts) { payout in
                        PayoutRow(payout: payout)
                    }
                }
            } else {
                Text(R.string.localizable.stripeNoPayouts())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.accountStatus == nil {
                Button {
                    Task {
                        await viewModel.createAccount()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(R.string.localizable.stripeCreateAccount())
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            if let status = viewModel.accountStatus, !status.requirements.currentlyDue.isEmpty {
                Button {
                    Task {
                        await viewModel.openOnboarding()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(R.string.localizable.stripeCompleteOnboarding())
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            if viewModel.accountStatus?.payoutsEnabled == true {
                Button {
                    viewModel.openStripeDashboard()
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text(R.string.localizable.stripeOpenDashboard())
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func formatAmount(_ amount: Int, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(amount) / 100.0)) ?? "\(amount / 100) \(currency)"
    }
}

// MARK: - Payout Row
private struct PayoutRow: View {
    let payout: StripePayoutSummary.Payout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatAmount(payout.amount, currency: payout.currency))
                    .font(.system(size: 15, weight: .semibold))
                
                if let date = payout.arrivalDate {
                    Text(formatDate(date))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if let status = payout.status {
                statusBadge(status)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatAmount(_ amount: Int, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(amount) / 100.0)) ?? "\(amount / 100) \(currency)"
    }
    
    private func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func statusBadge(_ status: String) -> some View {
        Text(status.capitalized)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.1))
            .clipShape(Capsule())
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "paid", "completed":
            return .green
        case "pending", "in_transit":
            return .orange
        case "failed", "canceled":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - ViewModel
@MainActor
final class ProviderStripeViewModel: ObservableObject {
    @Published var accountStatus: StripeAccountStatus?
    @Published var payoutsSummary: StripePayoutSummary?
    @Published var isLoading = false
    @Published var safariURL: URL?
    @Published var errorMessage: String?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load account status
        let statusResult = await engine.stripeConnectService.accountStatus()
        if case .success(let status) = statusResult {
            self.accountStatus = status
        }
        
        // Load payouts summary
        let payoutsResult = await engine.stripeConnectService.payoutsSummary()
        if case .success(let summary) = payoutsResult {
            self.payoutsSummary = summary
        }
    }
    
    func createAccount() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.stripeConnectService.createOrGetAccount()
        switch result {
        case .success:
            await load()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func openOnboarding() async {
        let result = await engine.stripeConnectService.onboardingLink()
        switch result {
        case .success(let response):
            if let url = URL(string: response.url) {
                safariURL = url
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func openStripeDashboard() {
        // TODO: Ouvrir le dashboard Stripe (URL à récupérer depuis le backend ou construire)
        if let url = URL(string: "https://dashboard.stripe.com") {
            safariURL = url
        }
    }
}

