import Foundation

// MARK: - Booking Model

struct Booking: Codable, Identifiable, Hashable {
    let id: String
    let providerId: String
    let customerId: String?           // ⬅️ NOUVEAU: ID du customer
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
    let progress: BookingProgress?  // Service progress tracking
    let transportDistanceKm: Double?
    let transportFee: Double?
    let customerAddressLat: Double?
    let customerAddressLng: Double?
    
    // Computed properties pour compatibilité
    var addressLat: Double? { customerAddressLat }
    var addressLng: Double? { customerAddressLng }
    let paymentMethod: PaymentMethod?
    let depositAmount: Double?
    let depositPaymentIntentId: String?
    let counterProposalDate: String?
    let counterProposalStartTime: String?
    let counterProposalEndTime: String?
    let counterProposalMessage: String?
    let counterProposalStatus: CounterProposalStatus?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case providerId
        case customerId
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
        case progress
        case transportDistanceKm = "transport_distance_km"
        case transportFee = "transport_fee"
        case customerAddressLat = "customer_address_lat"
        case customerAddressLng = "customer_address_lng"
        case paymentMethod = "payment_method"
        case depositAmount = "deposit_amount"
        case depositPaymentIntentId = "deposit_payment_intent_id"
        case counterProposalDate = "counter_proposal_date"
        case counterProposalStartTime = "counter_proposal_start_time"
        case counterProposalEndTime = "counter_proposal_end_time"
        case counterProposalMessage = "counter_proposal_message"
        case counterProposalStatus = "counter_proposal_status"
        case createdAt = "created_at"
    }

    // MARK: - Custom Decoder

    init(from decoder: Decoder) throws {
        let keys = try decoder.container(keyedBy: CodingKeys.self)

        id = try keys.decode(String.self, forKey: .id)
        providerId = (try? keys.decode(String.self, forKey: .providerId)) ?? ""
        
        // MARK: customerId — optional, may be missing or null
        if let rawCustomerId = try? keys.decode(String.self, forKey: .customerId) {
            let trimmed = rawCustomerId.trimmingCharacters(in: .whitespacesAndNewlines)
            customerId = (trimmed.isEmpty || trimmed == "<null>") ? nil : trimmed
        } else {
            customerId = nil
        }

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
        
        // MARK: progress — optional BookingProgress
        progress = try? keys.decode(BookingProgress.self, forKey: .progress)
        
        // MARK: Transport fees — optional
        transportDistanceKm = try? keys.decode(Double.self, forKey: .transportDistanceKm)
        transportFee = try? keys.decode(Double.self, forKey: .transportFee)
        customerAddressLat = try? keys.decode(Double.self, forKey: .customerAddressLat)
        customerAddressLng = try? keys.decode(Double.self, forKey: .customerAddressLng)
        
        // MARK: Payment method — optional
        paymentMethod = try? keys.decode(PaymentMethod.self, forKey: .paymentMethod)
        depositAmount = try? keys.decode(Double.self, forKey: .depositAmount)
        depositPaymentIntentId = try? keys.decode(String.self, forKey: .depositPaymentIntentId)
        
        // MARK: Counter proposal — optional
        counterProposalDate = try? keys.decode(String.self, forKey: .counterProposalDate)
        counterProposalStartTime = try? keys.decode(String.self, forKey: .counterProposalStartTime)
        counterProposalEndTime = try? keys.decode(String.self, forKey: .counterProposalEndTime)
        counterProposalMessage = try? keys.decode(String.self, forKey: .counterProposalMessage)
        counterProposalStatus = try? keys.decode(CounterProposalStatus.self, forKey: .counterProposalStatus)
        createdAt = try? keys.decode(String.self, forKey: .createdAt)
    }
}

// MARK: - BookingCustomer

struct BookingCustomer: Codable, Hashable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let vehicleType: VehicleType?
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case phone
        case vehicleType
    }
    
    // Memberwise init to allow manual construction (e.g. sample data)
    init(firstName: String, lastName: String, email: String, phone: String, vehicleType: VehicleType? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.vehicleType = vehicleType
    }
    
    // Custom decoder remains for robustness
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        vehicleType = try? container.decode(VehicleType.self, forKey: .vehicleType)
    }
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
    case started      // Service has started
    case inProgress   // Service is in progress (with progress tracking)
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

// MARK: - PaymentMethod

enum PaymentMethod: String, Codable {
    case card
    case cash
}

// MARK: - CounterProposalStatus

enum CounterProposalStatus: String, Codable {
    case none
    case pending
    case accepted
    case refused
}

// MARK: - Extensions

extension BookingCustomer {
    static let sampleAchraf = BookingCustomer(
        firstName: "Achraf",
        lastName: "Benali",
        email: "achraf@example.com",
        phone: "+32470123456",
        vehicleType: .berline // Utilise le nouveau type simplifié
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
    
    /// Returns the number of hours until the booking start time (negative if past)
    var hoursUntilBooking: Double? {
        guard let start = DateFormatters.isoDateTime(date: date, time: startTime ?? "00:00") else {
            return nil
        }
        return start.timeIntervalSinceNow / 3600.0
    }
    
    /// Returns true if the booking date has passed
    var isPast: Bool {
        guard let start = DateFormatters.isoDateTime(date: date, time: startTime ?? "00:00") else {
            return false
        }
        return start < Date()
    }
    
    /// Returns the refund percentage based on cancellation rules:
    /// - 48h or more: 100% refund
    /// - 24h to 48h: 50% refund
    /// - Less than 24h AND confirmed: service remboursé, frais transport conservés
    /// - Less than 24h AND pending: 0% refund (no refund)
    var refundPercentage: Double {
        guard let hours = hoursUntilBooking else {
            return 0.0
        }
        
        if hours >= 48.0 {
            return 100.0 // 100% refund
        } else if hours >= 24.0 {
            return 50.0 // 50% refund between 24h and 48h
        } else {
            // Moins de 24h
            if status == .confirmed {
                // Si confirmé : rembourser uniquement le service (pas les frais de transport)
                // Le pourcentage sera calculé dynamiquement dans refundAmount
                return -1.0 // Valeur spéciale pour indiquer "service seulement"
            } else {
                return 0.0 // Pas de remboursement si pending et < 24h
            }
        }
    }
    
    /// Returns the refund amount based on cancellation rules
    /// - Si < 24h ET confirmed : rembourser uniquement le service (pas les frais de transport)
    /// - Sinon : utiliser le pourcentage standard
    var refundAmount: Double {
        guard let hours = hoursUntilBooking else {
            return 0.0
        }
        
        // Si < 24h ET confirmed : rembourser uniquement le service
        if hours < 24.0 && status == .confirmed {
            let transportFee = transportFee ?? 0.0
            let servicePrice = price - transportFee
            return servicePrice // Rembourser uniquement le service, pas les frais de transport
        }
        
        // Sinon : utiliser le pourcentage standard
        let percentage = refundPercentage
        if percentage < 0 {
            // Cas spécial déjà géré ci-dessus
            return 0.0
        }
        return (price * percentage) / 100.0
    }
    
    /// Returns the service price (total - transport fees)
    var servicePrice: Double {
        let transport = transportFee ?? 0.0
        return price - transport
    }
    
    /// Returns the transport fee amount
    var transportFeeAmount: Double {
        transportFee ?? 0.0
    }
    
    /// Returns true if cancellation is allowed
    /// Rules:
    /// - pending: can cancel (12h or more before booking)
    /// - confirmed: can cancel (12h or more before booking)
    /// - declined: can cancel (mais pas de refund car preauthorized, rien n'a été prélevé)
    /// - cancelled, completed: cannot cancel
    var canCancel: Bool {
        // Ne peut pas annuler si déjà cancelled ou completed
        if status == .cancelled || status == .completed {
            return false
        }
        
        // Pour pending, confirmed, declined: peut annuler si > 12h avant
        guard let hours = hoursUntilBooking else {
            return false
        }
        return hours > 12.0
    }
    
    /// Returns true if modification is allowed (12h or more before booking)
    /// Only pending and confirmed can be modified
    var canModify: Bool {
        // Ne peut modifier que pending ou confirmed
        guard status == .pending || status == .confirmed else {
            return false
        }
        
        guard let hours = hoursUntilBooking else {
            return false
        }
        return hours > 12.0
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
    
    /// Returns true if the booking has expired (>6h without action from provider)
    /// A booking expires if:
    /// - Status is pending
    /// - Payment status is preauthorized or paid
    /// - More than 6 hours have passed since creation
    var isExpired: Bool {
        guard status == .pending else { return false }
        guard paymentStatus == .preauthorized || paymentStatus == .paid else { return false }
        
        guard let createdAtString = createdAt else { return false }
        
        // Parse createdAt (ISO 8601 format)
        guard let createdDate = DateFormatters.iso8601(createdAtString) else {
            return false
        }
        
        let hoursSinceCreation = Date().timeIntervalSince(createdDate) / 3600.0
        return hoursSinceCreation > 6.0
    }
    
    /// Returns the number of hours remaining before auto-cancellation (max 6h)
    var hoursUntilExpiration: Double? {
        guard status == .pending else { return nil }
        guard paymentStatus == .preauthorized || paymentStatus == .paid else { return nil }
        guard let createdAtString = createdAt else { return nil }
        guard let createdDate = DateFormatters.iso8601(createdAtString) else { return nil }
        
        let hoursSinceCreation = Date().timeIntervalSince(createdDate) / 3600.0
        let remaining = 6.0 - hoursSinceCreation
        return remaining > 0 ? remaining : nil
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
