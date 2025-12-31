//
//  CartView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct CartView: View {
    let engine: Engine
    @Binding var cartItems: [CartItem]
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckout = false
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if cartItems.isEmpty {
                    emptyCartView
                } else {
                    VStack(spacing: 0) {
                        // Items list
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(cartItems) { item in
                                    CartItemRow(
                                        item: item,
                                        onUpdateQuantity: { newQuantity in
                                            updateQuantity(item: item, quantity: newQuantity)
                                        },
                                        onRemove: {
                                            removeItem(item)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                        
                        // Total and checkout
                        VStack(spacing: 16) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            HStack {
                                Text(R.string.localizable.shopTotal())
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(String(format: "%.2f €", totalAmount))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 20)
                            
                            Button {
                                showCheckout = true
                            } label: {
                                Text(R.string.localizable.shopCheckout())
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .background(Color.black)
                    }
                }
            }
            .navigationTitle(R.string.localizable.shopCart())
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
        .sheet(isPresented: $showCheckout) {
            CheckoutView(
                engine: engine,
                cartItems: cartItems,
                onOrderPlaced: {
                    cartItems.removeAll()
                    dismiss()
                }
            )
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text(R.string.localizable.shopCartEmpty())
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(R.string.localizable.shopCartEmptyMessage())
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func updateQuantity(item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index] = CartItem(
                    id: item.id,
                    product: item.product,
                    quantity: quantity
                )
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    private func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }
}

// MARK: - Cart Item Row
private struct CartItemRow: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            AsyncImage(url: item.product.imageURL) { phase in
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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(item.formattedTotal)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Quantity controls
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button {
                        onUpdateQuantity(item.quantity - 1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 30)
                    
                    Button {
                        onUpdateQuantity(item.quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Button {
                    onRemove()
                } label: {
                    Text(R.string.localizable.shopRemove())
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

