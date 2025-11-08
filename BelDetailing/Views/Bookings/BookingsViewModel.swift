//
//  BookingsViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import Combine
import RswiftResources

@MainActor
final class BookingsViewModel: ObservableObject {
  @Published var upcoming: [Booking] = []
  @Published var history: [Booking] = []
  @Published var isLoading = false
  @Published var errorText: String?

  private let engine: Engine

  init(engine: Engine) { self.engine = engine }

  func load() async {
    isLoading = true; defer { isLoading = false }
    let res = await engine.bookingService.getBookings(scope: nil, status: nil)
    switch res {
    case .success(let list):
      let now = Date()
      let df = ISO8601DateFormatter()
      self.upcoming = list.filter { b in
        if let d = df.date(from: b.date + "T" + b.startTime + ":00Z") { return d >= now }
        return false
      }
      self.history = list.filter { !upcoming.contains($0) }
      StorageManager.shared.saveCachedBookings(list)
    case .failure(let err):
      let cache = StorageManager.shared.getCachedBookings()
      if !cache.isEmpty {
        self.upcoming = cache
        self.history = []
        self.errorText = R.string.localizable.apiErrorOfflineFallback()
      } else {
        self.errorText = err.localizedDescription
      }
    }
  }
}
