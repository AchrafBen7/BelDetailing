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
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var showCheckout = false
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        ZStack {
            Color(R.color.mainBackground.name).ignoresSafeArea()
            
            if cartItems.isEmpty {
                emptyCartView
            } else {
                VStack(spacing: 0) {
                    // Header
                    header
                    
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
                        .padding(.bottom, 120) // espace pour le CTA bas
                    }
                    
                    // Bottom CTA (Total + Checkout)
                    bottomCheckoutBar
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
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
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text(R.string.localizable.shopCart())
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(R.color.mainBackground.name))
    }
    
    // MARK: - Bottom Checkout Bar
    private var bottomCheckoutBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.black.opacity(0.1))
            
            VStack(spacing: 16) {
                // Total
                HStack {
                    Text(R.string.localizable.shopTotal())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f €", totalAmount))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(R.color.primaryText))
                }
                
                // Checkout button
                Button {
                    showCheckout = true
                } label: {
                    Text(R.string.localizable.shopCheckout())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(R.string.localizable.shopCartEmpty())
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))
            
            Text(R.string.localizable.shopCartEmptyMessage())
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "car.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(R.color.primaryText))
                    .lineLimit(2)
                
                Text(item.formattedTotal)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(R.color.primaryText))
            }
            
            Spacer()
            
            // Quantity controls
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        onUpdateQuantity(item.quantity - 1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(item.quantity > 1 ? .black : .gray)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(R.color.primaryText))
                        .frame(minWidth: 30)
                    
                    Button {
                        onUpdateQuantity(item.quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                }
                
                Button {
                    onRemove()
                } label: {
                    Text(R.string.localizable.shopRemove())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

