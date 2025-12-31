//
//  ProductDetailView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct ProductDetailView: View {
    let product: Product
    let engine: Engine
    let onAddToCart: (Product, Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = 1
    @State private var showAddedToCart = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Image
                    productImage
                    
                    // Info
                    productInfo
                    
                    // Description
                    if let description = product.description {
                        descriptionSection(description)
                    }
                    
                    // Add to cart button
                    addToCartButton
                }
            }
            .background(Color.black)
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
        .alert(R.string.localizable.shopAddedToCart(), isPresented: $showAddedToCart) {
            Button(R.string.localizable.commonOk()) {
                dismiss()
            }
        } message: {
            Text(R.string.localizable.shopProductAddedMessage())
        }
    }
    
    private var productImage: some View {
        AsyncImage(url: product.imageURL) { phase in
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
        .frame(height: 400)
        .clipped()
    }
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Level
            if let level = product.level {
                Text(level.uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Name
            Text(product.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Rating
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text("(\(product.reviewCount) \(R.string.localizable.shopReviews()))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Price
            HStack(spacing: 12) {
                Text(product.formattedPrice)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                if let promoPrice = product.promoPrice {
                    Text(String(format: "%.2f €", product.price))
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .strikethrough()
                }
            }
            
            // Quantity selector
            HStack {
                Text(R.string.localizable.shopQuantity())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(quantity > 1 ? .orange : .gray)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 40)
                    
                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.shopDescription())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
    }
    
    private var addToCartButton: some View {
        Button {
            onAddToCart(product, quantity)
            showAddedToCart = true
        } label: {
            HStack {
                Image(systemName: "cart.fill")
                Text(R.string.localizable.shopAddToCart())
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

