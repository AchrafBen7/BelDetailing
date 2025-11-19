//
//  ConfirmButton.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.


import SwiftUI
import RswiftResources

extension BookingStep3View {

    var confirmButton: some View {

        let servicePrice = Int(service.price)
        let appFee = 5
        let total = servicePrice + appFee

        return Button {
            goToConfirmation = true
        } label: {
            HStack {
                Image(systemName: "checkmark")
                Text("\(R.string.localizable.bookingPayNow()) \(total)€")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(30)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
