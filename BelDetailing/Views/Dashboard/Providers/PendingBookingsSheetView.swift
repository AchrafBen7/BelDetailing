//
//  PendingBookingsSheetView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct PendingBookingsSheetView: View {
    let date: Date
    let bookings: [Booking]
    let engine: Engine
    let onConfirm: (String) -> Void
    let onDecline: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var processingBookingId: String?
    
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
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                        
                        Text(R.string.localizable.availabilityNoPendingBookings())
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(R.string.localizable.availabilityNoPendingBookingsMessage())
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Date header
                            VStack(spacing: 8) {
                                Text(R.string.localizable.availabilityPendingBookingsFor())
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(formattedDate)
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 8)
                            
                            // Bookings list
                            ForEach(bookings) { booking in
                                PendingBookingCard(
                                    booking: booking,
                                    isProcessing: processingBookingId == booking.id,
                                    onConfirm: {
                                        processingBookingId = booking.id
                                        onConfirm(booking.id)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            processingBookingId = nil
                                            if bookings.count == 1 {
                                                dismiss()
                                            }
                                        }
                                    },
                                    onDecline: {
                                        processingBookingId = booking.id
                                        onDecline(booking.id)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            processingBookingId = nil
                                            if bookings.count == 1 {
                                                dismiss()
                                            }
                                        }
                                    }
                                )
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
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
                            .foregroundColor(.primary)
                    }
                }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with service info
            HStack(spacing: 12) {
                if let urlString = booking.providerBannerUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty, .failure:
                            Color.gray.opacity(0.2)
                        @unknown default:
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
                    
                    if let customer = booking.customer {
                        Text("\(customer.firstName) \(customer.lastName)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(booking.displayStartTime) • \(String(format: "%.2f €", booking.price))")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Address
            if !booking.address.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    Text(booking.address)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button {
                    onDecline()
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(R.string.localizable.dashboardDecline())
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isProcessing)
                
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
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isProcessing)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

