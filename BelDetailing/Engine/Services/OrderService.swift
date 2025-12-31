//
//  OrderService.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation

// MARK: - Protocol
protocol OrderService {
    func getOrders() async -> APIResponse<[Order]>
    func getOrder(id: String) async -> APIResponse<Order>
    func createOrder(request: CreateOrderRequest) async -> APIResponse<CreateOrderResponse>
    func cancelOrder(id: String) async -> APIResponse<Bool>
}

// MARK: - Network Implementation
final class OrderServiceNetwork: OrderService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getOrders() async -> APIResponse<[Order]> {
        await networkClient.call(
            endPoint: .ordersList,
            wrappedInData: true
        )
    }
    
    func getOrder(id: String) async -> APIResponse<Order> {
        await networkClient.call(
            endPoint: .orderDetail(id: id),
            wrappedInData: true
        )
    }
    
    func createOrder(request: CreateOrderRequest) async -> APIResponse<CreateOrderResponse> {
        // Convert CreateOrderRequest to dictionary
        guard let jsonData = try? JSONEncoder().encode(request),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return .failure(.unknownError)
        }
        
        // Use callRaw to get Data, then decode manually (like BookingService)
        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: .orderCreate,
            dict: dict
        )
        
        switch raw {
        case .failure(let err):
            return .failure(err)
            
        case .success(let data):
            do {
                // Try to decode with wrappedInData structure first
                if let container = try? JSONDecoder().decode(NetworkClient.APIContainer<CreateOrderResponse>.self, from: data) {
                    return .success(container.data)
                } else {
                    // Fallback: decode directly
                    let decoded = try JSONDecoder().decode(CreateOrderResponse.self, from: data)
                    return .success(decoded)
                }
            } catch {
                return .failure(.decodingError(decodingError: error))
            }
        }
    }
    
    func cancelOrder(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .orderCancel(id: id)
        )
    }
}

