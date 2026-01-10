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
    
    @StateObject var viewModel: BookingDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @StateObject var session = AppSession.shared
    
    @State  var showStartServiceConfirmation = false
    @State  var showProgressTracking = false
    @State  var showCounterProposal = false
    @State  var showCounterProposalResponse = false
    @State  var showReviewPrompt = false
    @State  var showCreateReview = false
    @State  var showSmartRebook = false
    
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
                        // Gros titre en heroTitle
                        Text(R.string.localizable.bookingDetailTitle() + ".")
                            .textView(style: .heroTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
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
            // On cache la barre de navigation pour éviter le doublon avec le header custom
            .toolbar(.hidden, for: .navigationBar)
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
                    // Afficher le prompt de review si booking completed et customer
                    if viewModel.booking.status == .completed && session.user?.role == .customer {
                        // Petit délai pour une meilleure UX
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                        showReviewPrompt = true
                    }
                }
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
            }
            .onChange(of: viewModel.booking.status) { newStatus in
                // Afficher le prompt quand le booking devient completed
                if newStatus == .completed && session.user?.role == .customer {
                    Task {
                        // Petit délai pour une meilleure UX
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                        showReviewPrompt = true
                    }
                }
            }
            .sheet(isPresented: $showReviewPrompt) {
                GoogleReviewPromptView(
                    booking: viewModel.booking,
                    engine: engine
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCreateReview) {
                CreateReviewView(
                    booking: viewModel.booking,
                    engine: engine
                )
            }
            .sheet(isPresented: $showSmartRebook) {
                if let suggestion = viewModel.smartRebookSuggestion {
                    SmartRebookView(
                        suggestion: suggestion,
                        engine: engine
                    )
                }
            }
        }
    }
}

