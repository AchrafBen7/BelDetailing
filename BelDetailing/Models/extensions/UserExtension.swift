//
//  UserExtension.swift
//  BelDetailing
//
//  Created by Achraf Benali on 15/11/2025.
//

import Foundation

extension User {

    var displayName: String {
        
        // CUSTOMER: Voornaam + Naam
        if let customer = customerProfile {
            let full = "\(customer.firstName) \(customer.lastName)"
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !full.isEmpty { return full }
        }

        // COMPANY: officiële naam
        if let company = companyProfile {
            let name = company.legalName.trimmingCharacters(in: .whitespaces)
            if !name.isEmpty { return name }
        }

        // PROVIDER: displayName
        if let provider = providerProfile {
            let name = provider.displayName.trimmingCharacters(in: .whitespaces)
            if !name.isEmpty { return name }
        }

        // DEFAULT fallback
        return email
    }
}
