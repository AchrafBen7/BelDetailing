//
//  LoadingView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct LoadingView: View {
  var body: some View {
    VStack(spacing: 12) {
      ProgressView()
      R.string.localizable.loaderDescription().textView(style: .sectionTitle)
    }
    .padding(.vertical, 24)
  }
}

#Preview { LoadingView() }
