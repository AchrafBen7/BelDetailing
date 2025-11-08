//
//  BookingsView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources
import Combine

struct BookingsView: View {
  @StateObject private var vm: BookingsViewModel

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: BookingsViewModel(engine: engine))
  }

  var body: some View {
    NavigationView {
      Group {
        if vm.isLoading {
          LoadingView()
        } else if vm.upcoming.isEmpty, vm.history.isEmpty {
          EmptyStateView(
            title: R.string.localizable.bookingsEmptyTitle(),
            message: R.string.localizable.bookingsEmptyMessage()
          )
        } else {
          List {
            if !vm.upcoming.isEmpty {
              Section(R.string.localizable.bookingsUpcoming()) {
                ForEach(vm.upcoming) { b in bookingCell(b) }
              }
            }
            if !vm.history.isEmpty {
              Section(R.string.localizable.bookingsHistory()) {
                ForEach(vm.history) { b in bookingCell(b) }
              }
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle(R.string.localizable.tabBookings())
    }
    .task { await vm.load() }
    .alert(vm.errorText ?? "", isPresented: .constant(vm.errorText != nil)) {
      Button(R.string.localizable.commonOk(), role: .cancel) { vm.errorText = nil }
    }
  }

  private func bookingCell(_ b: Booking) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      "\(b.providerName) • \(b.serviceName)"
        .textView(style: AppStyle.TextStyle.sectionTitle)

      "\(b.date) • \(b.startTime)–\(b.endTime)"
        .textView(style: AppStyle.TextStyle.description)

      HStack {
        String(format: "€ %.2f", b.price)
          .textView(style: AppStyle.TextStyle.description)

        Spacer()

        Text(b.status.rawValue.capitalized)
          .font(.system(size: 12, weight: .semibold))
          .padding(.horizontal, 10).padding(.vertical, 4)
          .background(Color(R.color.secondaryOrange))
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .foregroundStyle(.white)
      }
    }
    .padding(.vertical, 6)
  }
}

#Preview { BookingsView(engine: Engine(mock: true)) }
