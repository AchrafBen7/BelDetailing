//
//  Booking.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Models

struct Booking: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let providerName: String
    let serviceName: String
    let price: Double
    let date: String        // "yyyy-MM-dd"
    let startTime: String   // "HH:mm"
    let endTime: String     // "HH:mm"
    let address: String
    var status: BookingStatus
    let paymentStatus: PaymentStatus
    let paymentIntentId: String?
    let commissionRate: Double?
    let invoiceSent: Bool?
    let customer: BookingCustomer

    // 👉 NOUVEAU : URL de la bannière du detailer
    let providerBannerUrl: String?
}

struct BookingCustomer: Codable, Hashable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
}

enum BookingStatus: String, Codable {
    case pending, confirmed, declined, cancelled, completed
}

enum PaymentStatus: String, Codable {
    case pending          // Réservation effectuée
    case preauthorized    // Montant bloqué sur la carte
    case paid             // Paiement capturé après service
    case refunded         // Montant remboursé (annulation / litige)
    case failed           // Erreur de paiement
}

// MARK: - Samples
extension Booking {
    static var sampleValues: [Booking] {
        [
            Booking(
                id: "bkg_001",
                providerId: "prov_001",
                providerName: "Clean & Shine",
                serviceName: "Polissage complet",
                price: 120.0,
                date: "2025-12-15",
                startTime: "14:00",
                endTime: "15:30",
                address: "Avenue Louise 123, 1000 Bruxelles",
                status: .pending,
                paymentStatus: .preauthorized,
                paymentIntentId: "pi_12345",
                commissionRate: 0.10,
                invoiceSent: false,
                customer: .sampleAchraf,
                providerBannerUrl:"https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png"
            ),
            Booking(
                id: "bkg_002",
                providerId: "prov_002",
                providerName: "AutoClean Expert",
                serviceName: "Nettoyage intérieur",
                price: 80.0,
                date: "2025-12-16",
                startTime: "10:00",
                endTime: "11:00",
                address: "Rue de la Loi 75, 1000 Bruxelles",
                status: .confirmed,
                paymentStatus: .paid,
                paymentIntentId: "pi_98765",
                commissionRate: 0.10,
                invoiceSent: true,
                customer: .sampleAchraf,
                providerBannerUrl:"https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png"
            ),
            Booking(
                id: "bkg_003",
                providerId: "prov_003",
                providerName: "Detail Pro",
                serviceName: "Lavage extérieur",
                price: 50.0,
                date: "2025-12-10",
                startTime: "09:30",
                endTime: "10:15",
                address: "Boulevard Anspach 1, 1000 Bruxelles",
                status: .completed,
                paymentStatus: .refunded,
                paymentIntentId: "pi_22222",
                commissionRate: 0.10,
                invoiceSent: true,
                customer: .sampleAchraf,
                providerBannerUrl:"https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png"
            ),
            Booking(
                id: "bkg_004",
                providerId: "prov_004",
                providerName: "Clean & Shine",
                serviceName: "Polissage complet",
                price: 120.0,
                date: "2025-11-22",
                startTime: "14:00",
                endTime: "15:30",
                address: "Avenue Louise 123, 1000 Bruxelles",
                status: .pending,
                paymentStatus: .preauthorized,
                paymentIntentId: "pi_12345",
                commissionRate: 0.10,
                invoiceSent: false,
                customer: .sampleAchraf,
                providerBannerUrl:"https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png"
            ),
            Booking(
                id: "bkg_005",
                providerId: "prov_005",
                providerName: "Clean & Shine",
                serviceName: "Polissage complet",
                price: 120.0,
                date: "2025-11-25",
                startTime: "14:00",
                endTime: "15:30",
                address: "Avenue Louise 123, 1000 Bruxelles",
                status: .confirmed,
                paymentStatus: .paid,
                paymentIntentId: "pi_12345",
                commissionRate: 0.10,
                invoiceSent: false,
                customer: .sampleAchraf,
                providerBannerUrl:"https://res.cloudinary.com/dyigkyptj/image/upload/e_improve,w_300,h_600,c_thumb,g_auto/v1762979364/detail1_bdupvi.png"
            ),
            
        ]
    }
}

extension BookingCustomer {
    static let sampleAchraf = BookingCustomer(
        firstName: "Achraf",
        lastName: "Benali",
        email: "achraf@example.com",
        phone: "+32470123456"
    )
}
extension Booking {
  /// URL utilisée pour l’image de la carte de réservation
  var imageURL: String? {
    providerBannerUrl
  }
}
extension Booking {
    var isWithin24h: Bool {
        guard let start = DateFormatters.isoDateTime(date: date, time: startTime) else { return false }
        return start.timeIntervalSinceNow < 24 * 3600
    }
}
