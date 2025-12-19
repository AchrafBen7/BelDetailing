//
//  ProviderBookingCardView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 20/11/2025.
//

import SwiftUI
import RswiftResources

struct ProviderBookingCardView: View {
    let booking: Booking
    let onConfirm: () -> Void
    let onDecline: () -> Void

    var isPast: Bool {
        let time = booking.startTime ?? "00:00"
        return (DateFormatters.isoDateTime(date: booking.date, time: time) ?? Date()) < Date()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 14) {
                AsyncImage(url: URL(string: booking.imageURL ?? "")) { phase in
                    if let img = try? phase.image {
                        img.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {

                    Text("Client")
                        .font(.system(size: 16, weight: .semibold))

                    Text(booking.serviceName ?? "-")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))

                    Text(DateFormatters.humanDate(from: booking.date, time: booking.startTime ?? "00:00"))
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                }


                Spacer()

                Text(booking.status.localizedTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(booking.status.badgeBackground)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if !isPast {
                HStack {
                    if booking.status == .pending {
                        Button(action: onConfirm) {
                            Text(R.string.localizable.dashboardConfirm())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(14)
                        }
                    }

                    Button(action: onDecline) {
                        Text(R.string.localizable.dashboardDecline())
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.red.opacity(0.5))
                            )
                    }
                }
                .padding(.top, 4)
            }

        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 3)
    }
}
