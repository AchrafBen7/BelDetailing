//
//  BookingDetailView+CustomerActions.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

extension BookingDetailView {
    // MARK: - Customer Actions
    var customerActionsSection: some View {
        VStack(spacing: 12) {
            // Counter proposal response (if there's a pending counter proposal)
            if booking.counterProposalStatus == .pending {
                counterProposalResponseView
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
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            // Bouton pour créer un avis si le service est terminé
            if booking.status == .completed {
                Button {
                    showCreateReview = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Laisser un avis")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                // Bouton Smart Rebook
                Button {
                    showSmartRebook = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Réserver à nouveau")
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
    
    // MARK: - Counter Proposal Response View
    private var counterProposalResponseView: some View {
        VStack(spacing: 12) {
            Text(R.string.localizable.bookingCounterProposalReceived())
                .font(.system(size: 18, weight: .bold))
            
            if let date = booking.counterProposalDate,
               let time = booking.counterProposalStartTime {
                Text(R.string.localizable.bookingCounterProposalNewDate(
                    DateFormatters.humanDate(from: date, time: time)
                ))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            
            if let message = booking.counterProposalMessage {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.acceptCounterProposal()
                        showCounterProposalResponse = false
                    }
                } label: {
                    Text(R.string.localizable.bookingCounterProposalAccept())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    Task {
                        await viewModel.refuseCounterProposal()
                        showCounterProposalResponse = false
                    }
                } label: {
                    Text(R.string.localizable.bookingCounterProposalRefuse())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

