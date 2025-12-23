//
//  ProductService.swift
//  BelDetailing
//

import Foundation

// MARK: - Protocol
protocol ProductService {
    func getProducts(category: ProductCategory?, limit: Int?) async -> APIResponse<[Product]>
    func getRecommended(limit: Int?) async -> APIResponse<[Product]>
    func trackClick(productId: String) async -> APIResponse<Bool>
}

// MARK: - Network Implementation
final class ProductServiceNetwork: ProductService {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func getProducts(category: ProductCategory?, limit: Int?) async -> APIResponse<[Product]> {
        await networkClient.call(
            endPoint: .products,
            urlDict: [
                "category": category?.rawValue,
                "limit": limit
            ],
            wrappedInData: true
        )
    }

    func getRecommended(limit: Int?) async -> APIResponse<[Product]> {
        await networkClient.call(
            endPoint: .productsRecommended,
            urlDict: ["limit": limit],
            wrappedInData: true
        )
    }

    func trackClick(productId: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .productClick(id: productId))
    }
}
