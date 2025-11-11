//
//  CustomInputField.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//
import SwiftUI

struct CustomInputField: View {
  let icon: String
  let title: String
  let placeholder: String
  @Binding var text: String
  var isSecure: Bool = false
  var keyboardType: UIKeyboardType = .default

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Label
      Text(title)
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(.black)

      // Field
      HStack(spacing: 12) {
        Image(systemName: icon)
          .foregroundColor(.gray)
          .frame(width: 22)

        if isSecure {
          SecureField(placeholder, text: $text)
            .textInputAutocapitalization(.none)
            .keyboardType(keyboardType)
        } else {
          TextField(placeholder, text: $text)
            .textInputAutocapitalization(.none)
            .keyboardType(keyboardType)
        }
      }
      .frame(height: 58)
      .padding(.horizontal, 14)
      .background(Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(Color.gray.opacity(0.25), lineWidth: 1)
      )
      .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
  }
}
