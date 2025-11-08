
    //  EmptyStateView.swift
    //  BelDetailing
    //
    //  Created by Achraf Benali on 08/11/2025.
    //

import SwiftUI
import RswiftResources

struct EmptyStateView: View {
  let title: String
  let message: String

  var body: some View {
    VStack(spacing: 8) {
      // ✅ `textView` s’applique à une String, pas à Text()
      title.textView(
        style: AppStyle.TextStyle.sectionTitle,
        multilineAlignment: TextAlignment.center
      )

      message.textView(
        style: AppStyle.TextStyle.description,
        overrideColor: .secondary,
        multilineAlignment: TextAlignment.center
      )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(24)
  }
}

#Preview {
  EmptyStateView(title: "Vide", message: "Aucun élément à afficher.")
}

