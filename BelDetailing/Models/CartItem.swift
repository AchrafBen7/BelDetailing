//
//  CartItem.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation

struct CartItem: Codable, Identifiable, Hashable {
    let id: String
    let product: Product
    let quantity: Int
    
    var totalPrice: Double {
        (product.promoPrice ?? product.price) * Double(quantity)
    }
    
    var formattedTotal: String {
        String(format: "%.2f €", totalPrice)
    }
}

