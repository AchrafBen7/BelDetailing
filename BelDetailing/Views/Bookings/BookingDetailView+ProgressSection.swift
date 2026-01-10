//
//  BookingDetailView+ProgressSection.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

extension BookingDetailView {
    // MARK: - Progress Section
    var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(R.string.localizable.bookingDetailProgress())
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(viewModel.progressPercentage)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            ProgressView(value: Double(viewModel.progressPercentage), total: 100)
                .tint(.black)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Button {
                showProgressTracking = true
            } label: {
                Text(R.string.localizable.bookingDetailViewProgress())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

