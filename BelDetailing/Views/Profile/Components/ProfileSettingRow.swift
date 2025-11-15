//
//  ProfileSettingRow.swift
//  BelDetailing
//
//  Created by Achraf Benali on 15/11/2025.
//

import SwiftUI

struct ProfileSettingRow: View {
    let systemIcon: String
    let title: String

    var body: some View {
        HStack(spacing: 16) {

            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 48, height: 48)

                Image(systemName: systemIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}
