//
//  BookingDetailView+ProviderActions.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

extension BookingDetailView {
    // MARK: - Provider Actions
    var providerActionsSection: some View {
        VStack(spacing: 12) {
            // Counter proposal button (if booking is pending)
            if booking.status == .pending {
                Button {
                    showCounterProposal = true
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text(R.string.localizable.bookingProposeAlternativeDate())
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
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
        .sheet(isPresented: $showCounterProposal) {
            CounterProposalProviderView(booking: booking, engine: engine)
        }
    }
}

