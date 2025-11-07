//
//  City.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//


import Foundation

struct City: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let postalCode: String
    let lat: Double
    let lng: Double
}

// MARK: - Samples
extension City {
    static var sampleValues: [City] {
        [
            City(id: "brussels", name: "Bruxelles", postalCode: "1000", lat: 50.8503, lng: 4.3517),
            City(id: "liege", name: "Liège", postalCode: "4000", lat: 50.6333, lng: 5.5667),
            City(id: "namur", name: "Namur", postalCode: "5000", lat: 50.4669, lng: 4.8664),
            City(id: "gent", name: "Gand", postalCode: "9000", lat: 51.05, lng: 3.7167),
            City(id: "antwerp", name: "Anvers", postalCode: "2000", lat: 51.2194, lng: 4.4025)
        ]
    }
}
