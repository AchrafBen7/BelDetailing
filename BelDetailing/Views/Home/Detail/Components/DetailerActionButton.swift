//
//  DetailerActionButton.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI

struct DetailerActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(26)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
