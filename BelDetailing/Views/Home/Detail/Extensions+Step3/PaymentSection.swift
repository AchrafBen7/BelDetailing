//
//  PaymentSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
import SwiftUI
import RswiftResources

extension BookingStep3View {

    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(R.string.localizable.bookingPaymentTitle())
                .font(.system(size: 22, weight: .bold))

            VStack(spacing: 12) {
                ForEach(Payment.allCases, id: \.self) { method in

                    HStack(spacing: 14) {

                        Image(systemName: method.icon)
                            .font(.system(size: 22))
                            .frame(width: 28)

                        Text(method.title)
                            .font(.system(size: 17, weight: .medium))

                        Spacer()

                        if selectedPayment == method {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedPayment == method ? Color.black : Color(.secondarySystemBackground))
                    .foregroundColor(selectedPayment == method ? .white : .black)
                    .cornerRadius(20)
                    .onTapGesture { selectedPayment = method }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
