//
//  OrderHistoryView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import Combine

struct OrderHistoryView: View {
    let engine: Engine
    @StateObject private var viewModel: OrderHistoryViewModel
    @State private var selectedOrder: Order?
    
    init(engine: Engine) {
        self.engine = engine
        _viewModel = StateObject(wrappedValue: OrderHistoryViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView(message: R.string.localizable.commonLoading())
                        .tint(.white)
                } else if viewModel.orders.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: R.string.localizable.shopNoOrders(),
                            message: R.string.localizable.shopNoOrdersMessage(),
                            systemIcon: "bag"
                        )
                        .padding(.top, 60)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.orders) { order in
                                OrderCard(order: order) {
                                    selectedOrder = order
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(R.string.localizable.shopOrderHistory())
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedOrder) { order in
            OrderDetailView(order: order, engine: engine)
        }
    }
}

// MARK: - Order Card
private struct OrderCard: View {
    let order: Order
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("#\(order.id.prefix(8))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(order.status.localizedTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                // Items count
                Text("\(order.items.count) \(R.string.localizable.shopItems())")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                // Total
                HStack {
                    Text(R.string.localizable.shopTotal())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(order.formattedTotal)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                // Date
                Text(order.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Order Detail View
private struct OrderDetailView: View {
    let order: Order
    let engine: Engine
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Status
                        statusSection
                        
                        // Items
                        itemsSection
                        
                        // Shipping address
                        shippingSection
                        
                        // Total
                        totalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(R.string.localizable.shopOrderDetails())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.shopOrderStatus())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(order.status.localizedTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.orange)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.shopOrderItems())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(order.items) { item in
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: item.productImageUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty, .failure:
                            Color.gray.opacity(0.3)
                        @unknown default:
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.productName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(item.quantity) × \(String(format: "%.2f €", item.unitPrice))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.2f €", item.totalPrice))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var shippingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.shopShippingAddress())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(order.shippingAddress.firstName) \(order.shippingAddress.lastName)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text(order.shippingAddress.street)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("\(order.shippingAddress.postalCode) \(order.shippingAddress.city)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                if let phone = order.shippingAddress.phone {
                    Text(phone)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var totalSection: some View {
        HStack {
            Text(R.string.localizable.shopTotal())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(order.formattedTotal)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.orange)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - ViewModel
@MainActor
final class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.orderService.getOrders()
        if case .success(let orders) = result {
            self.orders = orders
        }
    }
}

