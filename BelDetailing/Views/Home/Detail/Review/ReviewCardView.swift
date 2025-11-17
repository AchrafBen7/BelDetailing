//
//  ReviewCardView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import RswiftResources

struct ReviewCardView: View {
    let review: Review

    private var formattedDate: String {
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: review.createdAt) else { return "" }

        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0

        let text = "\(days) jours"        // bv. "2 jours" / "3 dagen" enz.
        return R.string.localizable.detailReviewTime(text)
    }



    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // --- TOP ---
            HStack(alignment: .center, spacing: 12) {

                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(review.customerName.prefix(1)))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    )

                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        Text(review.customerName)
                            .font(.system(size: 17, weight: .semibold))

                        Text(R.string.localizable.detailVerified())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }

                    // Stars + durée
                    HStack(spacing: 4) {
                        ForEach(0..<review.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                        }

                        Text(formattedDate)
                            .foregroundColor(.gray)
                            .font(.system(size: 13))
                    }
                }
            }

            // Texte
            if let comment = review.comment {
                Text(comment)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }

        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }
}
