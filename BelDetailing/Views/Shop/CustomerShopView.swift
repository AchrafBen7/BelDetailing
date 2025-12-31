//
//  CustomerShopView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct CustomerShopView: View {
    let engine: Engine
    @StateObject private var viewModel: CustomerShopViewModel
    @State private var selectedProduct: Product?
    @State private var showCart = false
    @State private var cartItems: [CartItem] = []
    
    init(engine: Engine) {
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CustomerShopViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background white
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with image background and dark overlay
                        headerSection
                        
                        // Nouveautés disponibles
                        newArrivalsSection
                        
                        // Filtres catégories
                        categoryFiltersSection
                        
                        // All products grid
                        allProductsSection
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Floating Cart Button (only show if cart is not empty)
                if !cartItems.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showCart = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding(16)
                                        .background(Color.orange)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                                    
                                    Text("\(cartItems.reduce(0) { $0 + $1.quantity })")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product, engine: engine, onAddToCart: { product, quantity in
                addToCart(product: product, quantity: quantity)
            })
        }
        .sheet(isPresented: $showCart) {
            CartView(engine: engine, cartItems: $cartItems)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image with dark overlay - full screen
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty, .failure:
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.black.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                @unknown default:
                    Color.black
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                Color.black.opacity(0.75) // Very dark overlay
            )
            
            // Content
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NIOS SHOP")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.8))
                    Text(R.string.localizable.shopTitle())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Cart button instead of avatar
                Button {
                    if !cartItems.isEmpty {
                        showCart = true
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        if !cartItems.isEmpty {
                            Text("\(cartItems.reduce(0) { $0 + $1.quantity })")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50) // Safe area padding from top
            .padding(.bottom, 24)
        }
        .frame(height: 200)
        .ignoresSafeArea(edges: .top) // Full screen - no white space at top
    }
    
    // MARK: - New Arrivals Section
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.shopNewArrivals())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text(R.string.localizable.shopNewArrivalsSubtitle())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Badges
            HStack(spacing: 12) {
                BadgeView(
                    icon: "shield.fill",
                    text: R.string.localizable.shopQualityGuarantee()
                )
                BadgeView(
                    icon: "bolt.fill",
                    text: R.string.localizable.shopDelivery48h()
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Category Filters
    private var categoryFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: R.string.localizable.shopCategoryAll(),
                    isSelected: viewModel.selectedCategory == nil,
                    action: {
                        viewModel.selectedCategory = nil
                        Task { await viewModel.loadProducts() }
                    }
                )
                
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.localizedTitle,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            viewModel.selectedCategory = category
                            Task { await viewModel.loadProducts() }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
        .background(Color.white)
    }
    
    // MARK: - All Products Section
    private var allProductsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else if viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bag")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 60)
                    
                    Text(R.string.localizable.shopNoProducts())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(R.string.localizable.shopNoProductsMessage())
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Grid layout with 2 columns
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 20) {
                    ForEach(viewModel.products) { product in
                        ShopProductCard(
                            product: product,
                            onTap: {
                                selectedProduct = product
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 100)
        .background(Color.white)
    }
    
    // MARK: - Helpers
    private func addToCart(product: Product, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index] = CartItem(
                id: cartItems[index].id,
                product: product,
                quantity: cartItems[index].quantity + quantity
            )
        } else {
            cartItems.append(CartItem(
                id: UUID().uuidString,
                product: product,
                quantity: quantity
            ))
        }
    }
}

// MARK: - Badge View
private struct BadgeView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.orange)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .overlay(
            Capsule()
                .stroke(Color.orange, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Category Chip
private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Shop Product Card
private struct ShopProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with discount badge - Fixed size rectangle (EXACT same size for all)
            ZStack(alignment: .topLeading) {
                // Background container - exact same size
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 180)
                
                // Image - constrained to exact same size
                AsyncImage(url: product.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.3))
                    @unknown default:
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Discount badge
                if let promoPrice = product.promoPrice, promoPrice < product.price {
                    let discount = Int(((product.price - promoPrice) / product.price) * 100)
                    Text("-\(discount)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
            .frame(height: 180) // EXACT same height for ALL products
            .frame(maxWidth: .infinity) // Full width of card
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Level
            if let level = product.level {
                Text(level.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Name
            Text(product.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text(String(format: "%.1f", product.rating))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)
                Text("(\(product.reviewCount) avis)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // Price
            HStack(spacing: 8) {
                Text(product.formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                if let promoPrice = product.promoPrice {
                    Text(String(format: "%.2f €", product.price))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .strikethrough()
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}
