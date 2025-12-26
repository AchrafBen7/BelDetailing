//
//  ProviderDashboardHeaderView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import RswiftResources

struct ProviderDashboardHeaderView: View {

    let onViewOffers: () -> Void

    var body: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 6) {
                Text("Bureau.")
                    .textView(style: .heroTitle) // même rendu que Bookings
                Text(R.string.localizable.dashboardActivitySubtitle())
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: onViewOffers) {
                Text(R.string.localizable.dashboardMyOffers())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .padding(.top, 10) // descend légèrement le bouton
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.white)
    }
}
