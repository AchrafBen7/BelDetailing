//
//  Typography+TextView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI

struct AppTextModifier: ViewModifier {
  let style: AppStyle.TextStyle
  let overrideColor: Color?

  func body(content: Content) -> some View {
    content
      .font(style.font)
      .foregroundColor(overrideColor ?? style.defaultColor)
  }
}

extension Text {
  /// Gebruik AppStyle.TextStyle op een Text
  func textView(style: AppStyle.TextStyle, overrideColor: Color? = nil) -> some View {
    self.modifier(AppTextModifier(style: style, overrideColor: overrideColor))
  }
}
