//
//  BookingDetailView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct BookingDetailView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: BookingDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @StateObject private var session = AppSession.shared
    
    @State private var showStartServiceConfirmation = false
    @State private var showProgressTracking = false
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: BookingDetailViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header avec image
                        bookingHeader
                        
                        // Informations de base
                        bookingInfoSection
                        
                        // Progress tracking (si service en cours)
                        if viewModel.isServiceInProgress {
                            progressSection
                        }
                        
                        // Actions selon le rôle
                        if let userRole = session.user?.role {
                            switch userRole {
                            case .provider:
                                providerActionsSection
                            case .customer:
                                customerActionsSection
                            case .company:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.06).ignoresSafeArea()
                    ProgressView()
                }
            }
            .navigationTitle(R.string.localizable.bookingDetailTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(R.string.localizable.commonClose()) {
                        dismiss()
                    }
                }
            }
            .alert(R.string.localizable.bookingStartServiceConfirmTitle(), isPresented: $showStartServiceConfirmation) {
                Button(R.string.localizable.commonCancel(), role: .cancel) {}
                Button(R.string.localizable.bookingStartServiceConfirmButton()) {
                    Task {
                        await viewModel.startService()
                        if viewModel.errorMessage == nil {
                            showProgressTracking = true
                        }
                    }
                }
            } message: {
                Text(R.string.localizable.bookingStartServiceConfirmMessage())
            }
            .alert(R.string.localizable.errorTitle(), isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button(R.string.localizable.commonOk()) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .fullScreenCover(isPresented: $showProgressTracking) {
                if let userRole = session.user?.role {
                    switch userRole {
                    case .provider:
                        ServiceProgressTrackingProviderView(booking: viewModel.booking, engine: engine)
                    case .customer:
                        ServiceProgressTrackingCustomerView(booking: viewModel.booking, engine: engine)
                    case .company:
                        EmptyView()
                    }
                }
            }
            .onAppear {
                tabBarVisibility.isHidden = true
                Task {
                    await viewModel.load()
                }
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
            }
        }
    }
    
    // MARK: - Booking Header
    private var bookingHeader: some View {
        Group {
            if let urlString = booking.providerBannerUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2).overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.2)
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .frame(height: 200)
        .clipped()
        .overlay(alignment: .topTrailing) {
            BookingStatusBadge(status: viewModel.booking.status, paymentStatus: viewModel.booking.paymentStatus)
                .padding(10)
        }
    }
    
    // MARK: - Booking Info Section
    private var bookingInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingDetailInformation())
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 12) {
                InfoRow(label: R.string.localizable.bookingDetailService(), value: booking.displayServiceName)
                InfoRow(label: R.string.localizable.bookingDetailProvider(), value: booking.displayProviderName)
                InfoRow(label: R.string.localizable.bookingDetailDate(), value: DateFormatters.humanDate(from: booking.date, time: booking.displayStartTime))
                InfoRow(label: R.string.localizable.bookingDetailAddress(), value: booking.address)
                InfoRow(label: R.string.localizable.bookingDetailPrice(), value: String(format: "%.2f €", booking.price))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(R.string.localizable.bookingDetailProgress())
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(viewModel.progressPercentage)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            ProgressView(value: Double(viewModel.progressPercentage), total: 100)
                .tint(.black)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Button {
                showProgressTracking = true
            } label: {
                Text(R.string.localizable.bookingDetailViewProgress())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Provider Actions
    private var providerActionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.canStartService {
                Button {
                    showStartServiceConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(R.string.localizable.bookingStartService())
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            if viewModel.isServiceInProgress {
                Button {
                    showProgressTracking = true
                } label: {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text(R.string.localizable.bookingViewProgress())
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
    
    // MARK: - Customer Actions
    private var customerActionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.isServiceInProgress {
                Button {
                    showProgressTracking = true
                } label: {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text(R.string.localizable.bookingViewProgress())
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}

// MARK: - Info Row Component
private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.trailing)
        }
    }
}

