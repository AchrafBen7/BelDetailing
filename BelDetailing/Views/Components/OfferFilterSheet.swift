//
//  OfferFilterSheet.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct OfferFiltersSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var status: OfferStatus?
  @State private var type: OfferType?

  let onApply: (OfferStatus?, OfferType?) -> Void

  init(selectedStatus: OfferStatus?, selectedType: OfferType?,
       onApply: @escaping (OfferStatus?, OfferType?) -> Void) {
    _status = State(initialValue: selectedStatus)
    _type = State(initialValue: selectedType)
    self.onApply = onApply
  }

  var body: some View {
    NavigationView {
      Form {
        Section(R.string.localizable.filterStatus()) {
          Picker("Status", selection: $status) {
            Text(R.string.localizable.all()).tag(OfferStatus?.none)
            ForEach(OfferStatus.allCases, id: \.self) { s in
              Text(s.rawValue.capitalized).tag(OfferStatus?.some(s))
            }
          }
          .pickerStyle(.menu)
        }

        Section(R.string.localizable.filterType()) {
          Picker("Type", selection: $type) {
            Text(R.string.localizable.all()).tag(OfferType?.none)
            ForEach(OfferType.allCases, id: \.self) { t in
              Text(t.rawValue.capitalized).tag(OfferType?.some(t))
            }
          }
          .pickerStyle(.menu)
        }
      }
      .navigationTitle(R.string.localizable.offersFiltersTitle())
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(R.string.localizable.apply()) {
            onApply(status, type)
            dismiss()
          }
        }
        ToolbarItem(placement: .cancellationAction) {
          Button(R.string.localizable.cancel()) { dismiss() }
        }
      }
    }
  }
}

#Preview {
  OfferFiltersSheet(selectedStatus: nil, selectedType: nil) { _,_ in }
}
