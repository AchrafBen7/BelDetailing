//
//  UserInput.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
import SwiftUI

extension BookingStep2View {
    func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        height: CGFloat = 50
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.system(size: 15, weight: .semibold))

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.leading, 4)
                        .padding(.top, height == 110 ? 8 : 0)
                }

                if height == 110 {
                    TextEditor(text: text)
                        .frame(height: height)
                        .padding(6)
                } else {
                    TextField("", text: text)
                        .frame(height: height)
                        .padding(.horizontal, 6)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}
