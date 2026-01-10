//
//  PendingBookingsSheetView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Identifiable Booking Wrapper
private struct IdentifiableBooking: Identifiable {
    let id: String
    let booking: Booking
    
    init(booking: Booking) {
        self.id = booking.id
        self.booking = booking
    }
}

struct PendingBookingsSheetView: View {
    let date: Date
    let bookings: [Booking]
    let engine: Engine
    let viewModel: ProviderAvailabilityViewModel
    let onConfirm: @MainActor (String) async -> Void
    let onDecline: @MainActor (String) async -> Void
    let onCounterPropose: ((Booking) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var processingBookingId: String?
    @State private var bookingForCounterProposal: Booking?
    
    init(date: Date, bookings: [Booking], engine: Engine, viewModel: ProviderAvailabilityViewModel, onConfirm: @escaping @MainActor (String) async -> Void, onDecline: @escaping @MainActor (String) async -> Void, onCounterPropose: ((Booking) -> Void)? = nil) {
        self.date = date
        self.bookings = bookings
        self.engine = engine
        self.viewModel = viewModel
        self.onConfirm = onConfirm
        self.onDecline = onDecline
        self.onCounterPropose = onCounterPropose
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if bookings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text(R.string.localizable.availabilityNoPendingBookings())
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(R.string.localizable.availabilityNoPendingBookingsMessage())
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Date header - plus compact
                            HStack {
                                Text(formattedDate)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                            
                            // Bookings list
                            ForEach(bookings) { booking in
                                PendingBookingCard(
                                    booking: booking,
                                    isProcessing: processingBookingId == booking.id,
                                    onConfirm: {
                                        let bookingId = booking.id
                                        print("🟡 [PendingBookingsSheet] onConfirm button tapped")
                                        print("🟡 [PendingBookingsSheet] booking.id captured: '\(bookingId)'")
                                        print("🟡 [PendingBookingsSheet] booking.id type: \(type(of: bookingId))")
                                        print("🟡 [PendingBookingsSheet] booking.id isEmpty: \(bookingId.isEmpty)")
                                        
                                        Task { @MainActor in
                                            print("🟡 [PendingBookingsSheet] onConfirm Task started on MainActor")
                                            print("🟡 [PendingBookingsSheet] Setting processingBookingId...")
                                            processingBookingId = bookingId
                                            print("🟡 [PendingBookingsSheet] Clearing errorMessage...")
                                            viewModel.errorMessage = nil
                                            print("🟡 [PendingBookingsSheet] onConfirm - Calling onConfirm callback with id: '\(bookingId)'")
                                            
                                            do {
                                                print("🟡 [PendingBookingsSheet] About to await onConfirm...")
                                                await onConfirm(bookingId)
                                                print("🟡 [PendingBookingsSheet] onConfirm - Callback returned successfully")
                                            } catch {
                                                print("❌ [PendingBookingsSheet] onConfirm - Callback threw error: \(error)")
                                            }
                                            
                                            // Attendre un peu pour voir si une erreur est survenue
                                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 secondes
                                            
                                            print("🟡 [PendingBookingsSheet] Clearing processingBookingId...")
                                            processingBookingId = nil
                                            
                                            // Si c'était la dernière réservation et pas d'erreur, fermer le sheet
                                            if bookings.count == 1 && viewModel.errorMessage == nil {
                                                print("🟡 [PendingBookingsSheet] onConfirm - Closing sheet (last booking)")
                                                dismiss()
                                            }
                                        }
                                    },
                                    onDecline: {
                                        let bookingId = booking.id
                                        print("🟡 [PendingBookingsSheet] onDecline button tapped")
                                        print("🟡 [PendingBookingsSheet] booking.id captured: '\(bookingId)'")
                                        print("🟡 [PendingBookingsSheet] booking.id type: \(type(of: bookingId))")
                                        print("🟡 [PendingBookingsSheet] booking.id isEmpty: \(bookingId.isEmpty)")
                                        
                                        Task { @MainActor in
                                            print("🟡 [PendingBookingsSheet] onDecline Task started on MainActor")
                                            print("🟡 [PendingBookingsSheet] Setting processingBookingId...")
                                            processingBookingId = bookingId
                                            print("🟡 [PendingBookingsSheet] Clearing errorMessage...")
                                            viewModel.errorMessage = nil
                                            print("🟡 [PendingBookingsSheet] onDecline - Calling onDecline callback with id: '\(bookingId)'")
                                            
                                            do {
                                                print("🟡 [PendingBookingsSheet] About to await onDecline...")
                                                await onDecline(bookingId)
                                                print("🟡 [PendingBookingsSheet] onDecline - Callback returned successfully")
                                            } catch {
                                                print("❌ [PendingBookingsSheet] onDecline - Callback threw error: \(error)")
                                            }
                                            
                                            // Attendre un peu pour voir si une erreur est survenue
                                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 secondes
                                            
                                            print("🟡 [PendingBookingsSheet] Clearing processingBookingId...")
                                            processingBookingId = nil
                                            
                                            // Si c'était la dernière réservation et pas d'erreur, fermer le sheet
                                            if bookings.count == 1 && viewModel.errorMessage == nil {
                                                print("🟡 [PendingBookingsSheet] onDecline - Closing sheet (last booking)")
                                                dismiss()
                                            }
                                        }
                                    },
                                    onCounterPropose: {
                                        bookingForCounterProposal = booking
                                    }
                                )
                            }
                            
                            Spacer(minLength: 20)
                        }
                    }
                }
            }
            .navigationTitle(R.string.localizable.availabilityPendingBookings())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { bookingForCounterProposal.map { IdentifiableBooking(booking: $0) } },
            set: { bookingForCounterProposal = $0?.booking }
        )) { identifiableBooking in
            CounterProposalProviderView(booking: identifiableBooking.booking, engine: engine)
        }
        .alert("Erreur", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Pending Booking Card
private struct PendingBookingCard: View {
    let booking: Booking
    let isProcessing: Bool
    let onConfirm: () -> Void
    let onDecline: () -> Void
    let onCounterPropose: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Service info - compact
            HStack(spacing: 12) {
                // Image plus petite
                if let urlString = booking.providerBannerUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty, .failure:
                            Color.gray.opacity(0.15)
                        @unknown default:
                            Color.gray.opacity(0.15)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 48, height: 48)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(booking.displayServiceName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        if let customer = booking.customer {
                            Text("\(customer.firstName) \(customer.lastName)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text(booking.displayStartTime)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(String(format: "%.2f €", booking.price))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Address - compact
            if !booking.address.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(booking.address)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            
            // Temps restant - discret
            if let hoursRemaining = booking.hoursUntilExpiration {
                let hours = Int(hoursRemaining)
                let minutes = Int((hoursRemaining - Double(hours)) * 60)
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(hours)h \(minutes)min restantes")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Actions - style Uber (noir/gris)
            VStack(spacing: 0) {
                // Bouton contre-proposition - style outline
                if let onCounterPropose = onCounterPropose {
                    Button {
                        onCounterPropose()
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text("Proposer une autre date")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(isProcessing)
                    
                    Divider()
                        .padding(.horizontal, 16)
                }
                
                // Boutons Accept/Decline - style minimal
                HStack(spacing: 0) {
                    Button {
                        onDecline()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.primary)
                            } else {
                                Text(R.string.localizable.dashboardDecline())
                                    .font(.system(size: 15, weight: .medium))
                            }
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .disabled(isProcessing)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button {
                        onConfirm()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(R.string.localizable.dashboardConfirm())
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}

