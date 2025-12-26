//
//  Chip.swift
//  BelDetailing
//
//  Created by Achraf Benali on 25/12/2025.
//

import SwiftUI

struct ChipService: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isSelected ? Color.black : Color.black.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
    }
}
