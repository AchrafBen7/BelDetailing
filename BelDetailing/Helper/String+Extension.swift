//
//  String+Extension.swift
//  BelDetailing
//
//  Created by Achraf Benali on 05/11/2025.
//

import SwiftUI

extension String {
    func textView(
        style: AppStyle.TextStyle,
        overrideColor: Color? = nil,
        multilineAlignment: TextAlignment = .leading,
        lineLimit: Int? = nil
    ) -> some View {
        Text(self)
            .foregroundStyle(overrideColor ?? style.defaultColor)
            .font(style.font)
            .lineLimit(lineLimit)
            .multilineTextAlignment(multilineAlignment)
    }
}

