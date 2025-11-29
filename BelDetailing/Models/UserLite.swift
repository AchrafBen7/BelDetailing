//
//  UserLite.swift
//  BelDetailing
//
//  Created by Achraf Benali on 28/11/2025.
//

struct UserLite: Codable, Identifiable {
    let id: String
    let email: String
    let phone: String?
    let role: UserRole
    let vatNumber: String?
    let isVatValid: Bool?
}
