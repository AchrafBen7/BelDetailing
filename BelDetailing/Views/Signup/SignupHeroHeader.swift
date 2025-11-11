//
//  SignupHeroHeader.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
////
//  SignupHeroHeader.swift
//  BelDetailing
//
//  Created by Achraf Benali on 11/11/2025.
//

import SwiftUI
import RswiftResources

struct SignupHeroHeader: View {
  let onBack: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // flèche
      Button(action: onBack) {
        Image(systemName: "chevron.left")
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(.black)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }

      // titre + sous-titre
      VStack(alignment: .leading, spacing: 8) {
        Text(R.string.localizable.signupCreateAccountTitle())
          .font(.system(size: 42, weight: .heavy))
          .foregroundColor(.black)
          .multilineTextAlignment(.leading)

        Text(R.string.localizable.signupCreateAccountSubtitle())
          .font(.system(size: 18))
          .foregroundColor(.gray)
      }
    }
  }
}
