//
//  BookingDetailViewFromId.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources

/// Vue qui charge un booking depuis son ID et affiche BookingDetailView
struct BookingDetailViewFromId: View {
    let bookingId: String
    let engine: Engine
    
    @State private var booking: Booking?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let booking = booking {
                BookingDetailView(booking: booking, engine: engine)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text(errorMessage ?? R.string.localizable.errorTitle())
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(R.string.localizable.commonClose()) {
                        dismiss()
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .task {
            await loadBooking()
        }
    }
    
    private func loadBooking() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.bookingService.getBookingDetail(id: bookingId)
        switch result {
        case .success(let loadedBooking):
            booking = loadedBooking
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
