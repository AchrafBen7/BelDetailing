//
//  Order.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation

// MARK: - Order Model
struct Order: Codable, Identifiable, Hashable {
    let id: String
    let customerId: String
    let items: [OrderItem]
    let totalAmount: Double
    let shippingAddress: ShippingAddress
    let status: OrderStatus
    let paymentStatus: PaymentStatus
    let paymentIntentId: String?
    let createdAt: String
    let updatedAt: String
    let trackingNumber: String?
    let supplierId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case items
        case totalAmount = "total_amount"
        case shippingAddress = "shipping_address"
        case status
        case paymentStatus = "payment_status"
        case paymentIntentId = "payment_intent_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case trackingNumber = "tracking_number"
        case supplierId = "supplier_id"
    }
}

// MARK: - Order Item
struct OrderItem: Codable, Identifiable, Hashable {
    let id: String
    let productId: String
    let productName: String
    let productImageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case productName = "product_name"
        case productImageUrl = "product_image_url"
        case quantity
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
    }
}

// MARK: - Shipping Address
struct ShippingAddress: Codable, Hashable {
    let firstName: String
    let lastName: String
    let street: String
    let city: String
    let postalCode: String
    let country: String
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case street
        case city
        case postalCode = "postal_code"
        case country
        case phone
    }
}

// MARK: - Order Status
enum OrderStatus: String, Codable {
    case pending
    case confirmed
    case processing
    case shipped
    case delivered
    case cancelled
    case refunded
}

// MARK: - Create Order Request
struct CreateOrderRequest: Codable {
    let items: [CartItem]
    let shippingAddress: ShippingAddress
    
    enum CodingKeys: String, CodingKey {
        case items
        case shippingAddress = "shipping_address"
    }
}

// MARK: - Create Order Response
struct CreateOrderResponse: Decodable {
    let order: Order
    let clientSecret: String?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    private enum DataKeys: String, CodingKey {
        case order
        case clientSecret = "client_secret"
    }
    
    init(from decoder: Decoder) throws {
        if let root = try? decoder.container(keyedBy: CodingKeys.self),
           let data = try? root.nestedContainer(keyedBy: DataKeys.self, forKey: .data) {
            self.order = try data.decode(Order.self, forKey: .order)
            self.clientSecret = try? data.decode(String.self, forKey: .clientSecret)
            return
        }
        
        let flat = try decoder.container(keyedBy: DataKeys.self)
        self.order = try flat.decode(Order.self, forKey: .order)
        self.clientSecret = try? flat.decode(String.self, forKey: .clientSecret)
    }
}

// MARK: - Extensions
extension Order {
    var formattedTotal: String {
        String(format: "%.2f €", totalAmount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        if let date = DateFormatters.isoDate(createdAt) {
            return formatter.string(from: date)
        }
        return createdAt
    }
}

extension OrderStatus {
    var localizedTitle: String {
        switch self {
        case .pending: return "En attente"
        case .confirmed: return "Confirmée"
        case .processing: return "En traitement"
        case .shipped: return "Expédiée"
        case .delivered: return "Livrée"
        case .cancelled: return "Annulée"
        case .refunded: return "Remboursée"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed, .processing: return "blue"
        case .shipped: return "purple"
        case .delivered: return "green"
        case .cancelled, .refunded: return "red"
        }
    }
}
