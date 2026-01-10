//
//  BookingDetailView+Header.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

extension BookingDetailView {
    // MARK: - Booking Header
    var bookingHeader: some View {
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
}

