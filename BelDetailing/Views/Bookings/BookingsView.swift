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
  @StateObject private var viewModel: BookingsViewModel

  init(engine: Engine) {
    _viewModel = StateObject(wrappedValue: BookingsViewModel(engine: engine))
  }

  var body: some View {
    NavigationView {
      Group {
        if viewModel.isLoading {
          LoadingView()
        } else if viewModel.upcoming.isEmpty, viewModel.history.isEmpty {
          EmptyStateView(
            title: R.string.localizable.bookingsEmptyTitle(),
            message: R.string.localizable.bookingsEmptyMessage()
          )
        } else {
          List {
            if !viewModel.upcoming.isEmpty {
              Section(R.string.localizable.bookingsUpcoming()) {
                ForEach(viewModel.upcoming) { booking in
                  bookingCell(booking)
                }
              }
            }
            if !viewModel.history.isEmpty {
              Section(R.string.localizable.bookingsHistory()) {
                ForEach(viewModel.history) { booking in
                  bookingCell(booking)
                }
              }
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle(R.string.localizable.tabBookings())
    }
    .task { await viewModel.load() }
    .alert(viewModel.errorText ?? "", isPresented: .constant(viewModel.errorText != nil)) {
      Button(R.string.localizable.commonOk(), role: .cancel) {
        viewModel.errorText = nil
      }
    }
  }

  // MARK: - Row
  private func bookingCell(_ booking: Booking) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      "\(booking.providerName) • \(booking.serviceName)"
        .textView(style: AppStyle.TextStyle.sectionTitle)

      "\(booking.date) • \(booking.startTime)–\(booking.endTime)"
        .textView(style: AppStyle.TextStyle.description)

      HStack {
        String(format: "€ %.2f", booking.price)
          .textView(style: AppStyle.TextStyle.description)

        Spacer()

        Text(booking.status.rawValue.capitalized)
          .font(.system(size: 12, weight: .semibold))
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(Color(R.color.secondaryOrange))
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          .foregroundStyle(.white)
      }
    }
    .padding(.vertical, 6)
  }
}

#Preview {
  BookingsView(engine: Engine(mock: true))
}
