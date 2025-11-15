//
//  ProfileSummaryCard.swift
//  BelDetailing
//
//  Created by Achraf Benali on 15/11/2025.
//

import SwiftUI

struct ProfileSummaryCard: View {
    let user: User
    let subtitle: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {

                // Avatar cirkel
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 64, height: 64)

                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.gray)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
