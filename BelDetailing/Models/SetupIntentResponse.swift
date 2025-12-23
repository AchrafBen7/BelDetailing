//
//  SetupIntentResponse.swift
//  BelDetailing
//
//  Created by Achraf Benali on 23/12/2025.
//

import Foundation

struct SetupIntentResponse: Codable {
    let customerId: String
    let ephemeralKeySecret: String
    let setupIntentClientSecret: String
}
