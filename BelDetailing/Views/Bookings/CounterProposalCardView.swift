//
//  CounterProposalCardView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct CounterProposalCardView: View {
    let booking: Booking
    let onAccept: () -> Void
    let onRefuse: () -> Void
    let onTap: () -> Void
    
    @State private var isProcessing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec service et provider
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
                    
                    Text(booking.displayProviderName)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Contre-proposition
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    Text("Nouvelle proposition")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                if let date = booking.counterProposalDate,
                   let time = booking.counterProposalStartTime {
                    Text(DateFormatters.humanDate(from: date, time: time))
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                }
                
                if let message = booking.counterProposalMessage, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button {
                    isProcessing = true
                    onRefuse()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isProcessing = false
                    }
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Refuser")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isProcessing)
                
                Button {
                    isProcessing = true
                    onAccept()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isProcessing = false
                    }
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Accepter")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
        .onTapGesture {
            onTap()
        }
    }
}

