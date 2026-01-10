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
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 12) {
                ForEach(Payment.allCases, id: \.self) { method in
                    HStack(spacing: 16) {
                        Image(systemName: method.icon)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 32, height: 32)
                            .foregroundColor(selectedPayment == method ? .white : .black)

                        Text(method.title)
                            .font(.system(size: 17, weight: .medium))

                        Spacer()

                        if selectedPayment == method {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(selectedPayment == method ? Color.black : Color.gray.opacity(0.1))
                    .foregroundColor(selectedPayment == method ? .white : .black)
                    .cornerRadius(16)
                    .onTapGesture { selectedPayment = method }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}
