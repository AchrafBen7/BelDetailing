//
//  SignupViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 10/11/2025.
//

import Foundation
import Combine

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var selectedRole: UserRole? = nil

  private let userService: UserService

  init(engine: Engine) {
    self.userService = engine.userService
  }

  func registerUser(email: String, password: String, name: String) async -> Bool {
    let payload: [String: Any] = [
      "email": email,
      "password": password,
      "name": name,
      "role": selectedRole?.rawValue ?? "customer"
    ]

    let result = await userService.register(payload: payload)
    switch result {
    case .success:
      return true
    case .failure:
      return false
    }
  }
}
