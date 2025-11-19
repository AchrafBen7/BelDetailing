//
//  CustomBackButton.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//

import SwiftUI

struct CustomBackButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(12)
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .background(
            Color(.systemGroupedBackground)
                .opacity(0.98)
        )
    }
}
