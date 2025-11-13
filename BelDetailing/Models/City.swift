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
            // === Région Bruxelles-Capitale ===
            City(id: "brussels", name: "Bruxelles", postalCode: "1000", lat: 50.8503, lng: 4.3517),

            // === Wallonie ===
            City(id: "liege", name: "Liège", postalCode: "4000", lat: 50.6333, lng: 5.5667),
            City(id: "namur", name: "Namur", postalCode: "5000", lat: 50.4669, lng: 4.8664),
            City(id: "charleroi", name: "Charleroi", postalCode: "6000", lat: 50.4114, lng: 4.4447),
            City(id: "mons", name: "Mons", postalCode: "7000", lat: 50.4542, lng: 3.9567),
            City(id: "tournai", name: "Tournai", postalCode: "7500", lat: 50.6071, lng: 3.3896),
            City(id: "louvainlaNeuve", name: "Louvain-la-Neuve", postalCode: "1348", lat: 50.6683, lng: 4.6117),
            City(id: "arlon", name: "Arlon", postalCode: "6700", lat: 49.6833, lng: 5.8167),
            City(id: "dinant", name: "Dinant", postalCode: "5500", lat: 50.2608, lng: 4.9117),
            City(id: "bastogne", name: "Bastogne", postalCode: "6600", lat: 50.0006, lng: 5.7169),
            City(id: "wavre", name: "Wavre", postalCode: "1300", lat: 50.7175, lng: 4.6014),
            City(id: "nivelles", name: "Nivelles", postalCode: "1400", lat: 50.597, lng: 4.329),

            // === Flandre ===
            City(id: "gent", name: "Gand", postalCode: "9000", lat: 51.05, lng: 3.7167),
            City(id: "antwerp", name: "Anvers", postalCode: "2000", lat: 51.2194, lng: 4.4025),
            City(id: "bruges", name: "Bruges", postalCode: "8000", lat: 51.2089, lng: 3.2242),
            City(id: "leuven", name: "Louvain", postalCode: "3000", lat: 50.8796, lng: 4.7009),
            City(id: "mechelen", name: "Malines", postalCode: "2800", lat: 51.025, lng: 4.4776),
            City(id: "kortrijk", name: "Courtrai", postalCode: "8500", lat: 50.826, lng: 3.264),
            City(id: "roeselare", name: "Roulers", postalCode: "8800", lat: 50.946, lng: 3.122),
            City(id: "ostend", name: "Ostende", postalCode: "8400", lat: 51.2167, lng: 2.9),
            City(id: "hasselt", name: "Hasselt", postalCode: "3500", lat: 50.9311, lng: 5.3378),
            City(id: "genk", name: "Genk", postalCode: "3600", lat: 50.9667, lng: 5.5),
            City(id: "aalst", name: "Alost", postalCode: "9300", lat: 50.936, lng: 4.041),
            City(id: "stNiklaas", name: "Saint-Nicolas", postalCode: "9100", lat: 51.1667, lng: 4.1333),
            City(id: "turnhout", name: "Turnhout", postalCode: "2300", lat: 51.322, lng: 4.944),
            City(id: "lokeren", name: "Lokeren", postalCode: "9160", lat: 51.1, lng: 3.983),
            City(id: "oudenaarde", name: "Audenaerde", postalCode: "9700", lat: 50.85, lng: 3.6),

            // === Petites villes clés ===
            City(id: "eupen", name: "Eupen", postalCode: "4700", lat: 50.628, lng: 6.033),
            City(id: "malmedy", name: "Malmedy", postalCode: "4960", lat: 50.426, lng: 6.028),
            City(id: "spa", name: "Spa", postalCode: "4900", lat: 50.483, lng: 5.867),
            City(id: "marchenFamenne", name: "Marche-en-Famenne", postalCode: "6900", lat: 50.227, lng: 5.342)
        ]
    }
}
