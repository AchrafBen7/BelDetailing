//
//  CustomerShopViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine

@MainActor
final class CustomerShopViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var products: [Product] = []
    @Published var recommendedProducts: [Product] = []
    @Published var selectedCategory: ProductCategory?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load all products (not just recommended)
        await loadProducts()
    }
    
    func loadRecommended() async {
        let result = await engine.productService.getRecommended(limit: 6)
        if case .success(let products) = result {
            recommendedProducts = products
        }
    }
    
    func loadProducts() async {
        let result = await engine.productService.getProducts(
            category: selectedCategory,
            limit: nil
        )
        if case .success(let products) = result {
            self.products = products
        } else {
            self.products = []
        }
    }
}

