//
//  BookingCancelSheetView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//

import SwiftUI
import RswiftResources

struct BookingCancelSheetView: View {

    let booking: Booking
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 22) {

            // Title
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(R.string.localizable.bookingCancelConfirmTitle())
                    .font(.system(size: 22, weight: .bold))
            }
            .padding(.top, 20)

            Text(R.string.localizable.bookingCancelConfirmSubtitle())
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(R.string.localizable.bookingPrice())
                    Spacer()
                    Text("\(Int(booking.price))€")
                }

                HStack {
                    Text(R.string.localizable.bookingCancelFeeFull())
                        .foregroundColor(.red)
                    Spacer()
                    Text("-\(Int(booking.price))€")
                        .foregroundColor(.red)
                }

                Divider()

                HStack {
                    Text(R.string.localizable.bookingRefund())
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text("0€")
                }

                Text(R.string.localizable.bookingCancel24hRule())
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            Spacer()

            // Confirm
            Button {
                print("CONFIRM CANCEL")
                dismiss()
            } label: {
                Text(R.string.localizable.bookingCancelConfirmButton())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 20)

            // Back
            Button {
                dismiss()
            } label: {
                Text(R.string.localizable.commonBack())
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray.opacity(0.3))
                    )
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)
        }
        .presentationDetents([.height(600)])
    }
}
