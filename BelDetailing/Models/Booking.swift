import Foundation

// MARK: - Booking Model

struct Booking: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let providerName: String
    let serviceName: String
    let price: Double
    let date: String
    let startTime: String
    let endTime: String
    let address: String
    var status: BookingStatus
    let paymentStatus: PaymentStatus
    let paymentIntentId: String?
    let commissionRate: String?
    let invoiceSent: Bool
    let customer: BookingCustomer
    let providerBannerUrl: String? // URL for card banner

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case providerId = "provider_id"
        case providerName = "provider_name"
        case serviceName = "service_name"
        case price
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case address
        case status
        case paymentStatus = "payment_status"
        case paymentIntentId = "payment_intent_id"
        case commissionRate = "commission_rate"
        case invoiceSent = "invoice_sent"
        case customer
        case providerBannerUrl = "provider_banner_url"
    }

    // MARK: - Custom Decoder

    init(from decoder: Decoder) throws {
        let keys = try decoder.container(keyedBy: CodingKeys.self)

        id = try keys.decode(String.self, forKey: .id)
        providerId = try keys.decode(String.self, forKey: .providerId)
        providerName = try keys.decode(String.self, forKey: .providerName)
        serviceName = try keys.decode(String.self, forKey: .serviceName)
        price = try keys.decode(Double.self, forKey: .price)
        date = try keys.decode(String.self, forKey: .date)
        startTime = try keys.decode(String.self, forKey: .startTime)
        endTime = try keys.decode(String.self, forKey: .endTime)
        address = try keys.decode(String.self, forKey: .address)

        status = try keys.decode(BookingStatus.self, forKey: .status)
        paymentStatus = try keys.decode(PaymentStatus.self, forKey: .paymentStatus)

        // MARK: paymentIntentId can be "<null>"
        let piRaw = try? keys.decode(String.self, forKey: .paymentIntentId)
        paymentIntentId = (piRaw == "<null>" ? nil : piRaw)

        // MARK: commissionRate (string)
        commissionRate = try? keys.decode(String.self, forKey: .commissionRate)

        // MARK: invoiceSent (can be Bool OR Int)
        if let boolVal = try? keys.decode(Bool.self, forKey: .invoiceSent) {
            invoiceSent = boolVal
        } else if let intVal = try? keys.decode(Int.self, forKey: .invoiceSent) {
            invoiceSent = (intVal == 1)
        } else {
            invoiceSent = false
        }

        // MARK: provider banner
        let bannerRaw = try? keys.decode(String.self, forKey: .providerBannerUrl)
        providerBannerUrl = (bannerRaw == "<null>" ? nil : bannerRaw)

        customer = try keys.decode(BookingCustomer.self, forKey: .customer)
    }
}

// MARK: - BookingCustomer

struct BookingCustomer: Codable, Hashable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
}

// MARK: - Create Booking Response

struct CreateBookingResponse: Codable {
    let booking: Booking
    let clientSecret: String
}

// MARK: - BookingStatus

enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case declined
    case cancelled
    case completed
}

// MARK: - PaymentStatus

enum PaymentStatus: String, Codable {
    case pending          // Réservation effectuée
    case preauthorized    // Montant bloqué sur la carte
    case paid             // Paiement capturé après service
    case refunded         // Annulation / litige
    case failed           // Erreur de paiement
}

// MARK: - Extensions

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
    /// Retourne true si la réservation est dans les 24 prochaines heures
    var isWithin24h: Bool {
        guard let start = DateFormatters.isoDateTime(date: date, time: startTime) else {
            return false
        }
        return start.timeIntervalSinceNow < 24 * 3600
    }
}
