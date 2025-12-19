import Foundation

// MARK: - Booking Model

struct Booking: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let providerName: String?
    let serviceName: String?          // ⬅️ optionnel
    let price: Double
    let date: String
    let startTime: String?            // ⬅️ optionnel
    let endTime: String?              // ⬅️ optionnel
    let address: String
    var status: BookingStatus
    let paymentStatus: PaymentStatus
    let paymentIntentId: String?
    let commissionRate: String?
    let invoiceSent: Bool
    let customer: BookingCustomer?
    let providerBannerUrl: String?
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id
        case providerId
        case providerName
        case serviceName
        case price
        case date
        case startTime
        case endTime
        case address
        case status
        case paymentStatus
        case paymentIntentId
        case commissionRate
        case invoiceSent
        case customer
        case providerBannerUrl
        case currency
    }

    // MARK: - Custom Decoder

    init(from decoder: Decoder) throws {
        let keys = try decoder.container(keyedBy: CodingKeys.self)

        id = try keys.decode(String.self, forKey: .id)
        providerId = (try? keys.decode(String.self, forKey: .providerId)) ?? ""

        // providerName peut être manquant, null, "<null>" ou vide
        if let rawProviderName = try? keys.decode(String.self, forKey: .providerName) {
            let trimmed = rawProviderName.trimmingCharacters(in: .whitespacesAndNewlines)
            providerName = (trimmed.isEmpty || trimmed == "<null>") ? nil : trimmed
        } else {
            providerName = nil
        }

        // serviceName peut être manquant, null, "<null>" ou vide
        if let rawServiceName = try? keys.decode(String.self, forKey: .serviceName) {
            let trimmed = rawServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
            serviceName = (trimmed.isEmpty || trimmed == "<null>") ? nil : trimmed
        } else {
            serviceName = nil
        }

        price = try keys.decode(Double.self, forKey: .price)
        date = try keys.decode(String.self, forKey: .date)

        // ⬇️ startTime / endTime optionnels, acceptent absence ou "<null>"
        if let rawStart = try? keys.decode(String.self, forKey: .startTime) {
            let trimmed = rawStart.trimmingCharacters(in: .whitespacesAndNewlines)
            startTime = (trimmed.isEmpty || trimmed == "<null>") ? nil : trimmed
        } else {
            startTime = nil
        }

        if let rawEnd = try? keys.decode(String.self, forKey: .endTime) {
            let trimmed = rawEnd.trimmingCharacters(in: .whitespacesAndNewlines)
            endTime = (trimmed.isEmpty || trimmed == "<null>") ? nil : trimmed
        } else {
            endTime = nil
        }

        address = try keys.decode(String.self, forKey: .address)

        status = try keys.decode(BookingStatus.self, forKey: .status)

        // ⬇️ paymentStatus tolérant: clé absente/null/valeur inconnue -> .pending
        if let statusDecoded = try? keys.decode(PaymentStatus.self, forKey: .paymentStatus) {
            paymentStatus = statusDecoded
        } else if let raw = try? keys.decode(String.self, forKey: .paymentStatus),
                  let statusFromRaw = PaymentStatus(rawValue: raw) {
            paymentStatus = statusFromRaw
        } else {
            paymentStatus = .pending
        }

        // MARK: providerBannerUrl — may be string OR "<null>" OR ""
        let bannerRaw = try? keys.decode(String.self, forKey: .providerBannerUrl)
        if let raw = bannerRaw?.trimmingCharacters(in: .whitespacesAndNewlines),
           !raw.isEmpty, raw != "<null>" {
            providerBannerUrl = raw
        } else {
            providerBannerUrl = nil
        }

        // Customer may be null
        customer = try? keys.decode(BookingCustomer.self, forKey: .customer)

        // MARK: paymentIntentId — can be "<null>"
        let piRaw = try? keys.decode(String.self, forKey: .paymentIntentId)
        paymentIntentId = (piRaw == "<null>" ? nil : piRaw)

        // MARK: commissionRate — can be String OR Number
        if let str = try? keys.decode(String.self, forKey: .commissionRate) {
            commissionRate = str
        } else if let dbl = try? keys.decode(Double.self, forKey: .commissionRate) {
            commissionRate = String(dbl)
        } else {
            commissionRate = nil
        }

        // MARK: invoiceSent — may be Bool OR Int
        if let boolVal = try? keys.decode(Bool.self, forKey: .invoiceSent) {
            invoiceSent = boolVal
        } else if let intVal = try? keys.decode(Int.self, forKey: .invoiceSent) {
            invoiceSent = (intVal == 1)
        } else {
            invoiceSent = false
        }

        currency = (try? keys.decode(String.self, forKey: .currency)) ?? "eur"
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

struct CreateBookingResponse: Decodable {
    let booking: Booking
    let clientSecret: String?

    private enum CodingKeys: String, CodingKey {
        case data
    }

    private enum DataKeys: String, CodingKey {
        case booking
        case clientSecret
    }

    init(from decoder: Decoder) throws {

        // 🔥 Normal case: { "data": { booking, clientSecret } }
        if let root = try? decoder.container(keyedBy: CodingKeys.self),
           let data = try? root.nestedContainer(keyedBy: DataKeys.self, forKey: .data) {

            self.booking = try data.decode(Booking.self, forKey: .booking)
            self.clientSecret = try? data.decode(String.self, forKey: .clientSecret)
            return
        }

        // 🔥 Flat fallback: { booking, clientSecret }
        let flat = try decoder.container(keyedBy: DataKeys.self)
        self.booking = try flat.decode(Booking.self, forKey: .booking)
        self.clientSecret = try? flat.decode(String.self, forKey: .clientSecret)
    }
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
    case pending
    case preauthorized
    case processing   // présent dans tes logs
    case paid
    case refunded
    case failed
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
    var imageURL: String? { providerBannerUrl }

    var isWithin24h: Bool {
        guard let start = DateFormatters.isoDateTime(date: date, time: startTime ?? "00:00") else {
            return false
        }
        return start.timeIntervalSinceNow < 24 * 3600
    }

    // Affichage robuste pour l'heure de début
    var displayStartTime: String {
        startTime ?? "—"
    }

    // Affichage robuste pour les noms
    var displayProviderName: String {
        if let name = providerName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name
        }
        return "—"
    }

    var displayServiceName: String {
        if let name = serviceName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name
        }
        return "—"
    }
}

extension CreateBookingResponse {
    static func decodeFromBookingResponse(_ data: Data) throws -> CreateBookingResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(CreateBookingResponse.self, from: data)
    }
}
