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
    
    // MARK: - Validation
    
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let digits = self.filter { $0.isNumber }
        return digits.count >= 8 && digits.count <= 12
    }
}
