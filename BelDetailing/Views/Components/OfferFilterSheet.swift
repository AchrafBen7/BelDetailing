//
//  OfferFiltersSheet.swift
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
        // MARK: - Status Picker
        Section(R.string.localizable.filterStatus()) {
          OfferStatusPicker(status: $status)
        }

        // MARK: - Type Picker
        Section(R.string.localizable.filterType()) {
          OfferTypePicker(type: $type)
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
          Button(R.string.localizable.bookingCancel()) {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  OfferFiltersSheet(selectedStatus: nil, selectedType: nil) { _, _ in }
}

// MARK: - OfferStatusPicker
struct OfferStatusPicker: View {
  @Binding var status: OfferStatus?

  var body: some View {
    Picker("Status", selection: $status) {
      Text(R.string.localizable.all()).tag(nil as OfferStatus?)
      ForEach(OfferStatus.allCases, id: \.self) { statusCase in
        Text(statusCase.rawValue.capitalized)
          .tag(Optional(statusCase))
      }
    }
    .pickerStyle(.menu)
  }
}

// MARK: - OfferTypePicker
struct OfferTypePicker: View {
  @Binding var type: OfferType?

  var body: some View {
    Picker("Type", selection: $type) {
      Text(R.string.localizable.all()).tag(nil as OfferType?)
        ForEach(OfferType.allCases, id: \.self) { typeCase in
          Text(typeCase.rawValue.capitalized)
            .tag(Optional(typeCase))
        }
    }
    .pickerStyle(.menu)
  }
}
