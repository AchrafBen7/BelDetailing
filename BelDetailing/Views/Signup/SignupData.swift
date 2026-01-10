//
//  SignupData.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

struct SignupData {
    // Common
    let email: String
    let password: String
    let phone: String
    let vatNumber: String?
    
    // Customer
    let customerFirstName: String?
    let customerLastName: String?
    let customerVehicleType: VehicleType?
    let customerAddress: String?
    
    // Company
    let companyLegalName: String?
    let companyTypeId: String?
    let companyCity: String?
    let companyPostalCode: String?
    let companyContactName: String?
    
    // Provider
    let providerDisplayName: String?
    let providerBaseCity: String?
    let providerPostalCode: String?
    let providerMinPrice: Double?
    let providerHasMobileService: Bool?
    // Note: providerTransportPricePerKm n'est plus utilisé - les frais sont fixes (zones avec plafond 20€)
    let providerCompanyName: String?
    let providerBio: String?
}

