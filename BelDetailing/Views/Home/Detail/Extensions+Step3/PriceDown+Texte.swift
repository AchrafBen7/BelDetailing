//
//  PriceDown.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
import SwiftUI
import RswiftResources
extension BookingStep3View {

    var priceBreakdownSection: some View {

        let servicePrice = Int(service.price)
        let appFee = 5
        let total = servicePrice + appFee

        return VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text(R.string.localizable.bookingPriceService())
                Spacer()
                Text("\(servicePrice)€")
            }

            HStack {
                Text(R.string.localizable.bookingPriceFee())
                Spacer()
                Text("\(appFee)€")
            }

            Divider()

            HStack {
                Text(R.string.localizable.bookingTotal())
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(total)€")
                    .font(.system(size: 20, weight: .bold))
            }

        }
        .padding(.vertical, 16)
        .padding(.horizontal, cardInset)   // 👈 EXACTEMENT la même marge
        .background(Color.white)
        .cornerRadius(20)
    }
}

extension BookingStep3View {

    var termsSection: some View {
        VStack(spacing: 4) {
            Text(R.string.localizable.bookingTerms1())
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Button(R.string.localizable.bookingTermsConditions()) { }
                    .font(.system(size: 14, weight: .semibold))

                Text(R.string.localizable.bookingTermsAnd())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button(R.string.localizable.bookingTermsCancelPolicy()) { }
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal, 20)
    }
}
