//
//  ProfileViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published var user: User?
  @Published var isLoading = false
  @Published var errorText: String?

  private let engine: Engine

  init(engine: Engine) { self.engine = engine }

  func load() async {
    isLoading = true; defer { isLoading = false }
    if let cached = StorageManager.shared.getUser() {
      self.user = cached
    }
    let res = await engine.userService.me()
    switch res {
    case .success(let u):
      self.user = u
      StorageManager.shared.saveUser(u)
    case .failure(let err):
      if user == nil { errorText = err.localizedDescription }
    }
  }

  func logout() {
    StorageManager.shared.clearSession()
    user = nil
  }
}
