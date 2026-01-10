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
    @Binding var cartItems: [CartItem]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    @State private var quantity = 1
    @State private var showAddedToCart = false

    var body: some View {
        ZStack {
            Color(R.color.mainBackground.name).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header image plein haut sans espace blanc + bouton close overlay
                    headerImageWithClose

                    // Contenu compact
                    VStack(alignment: .leading, spacing: 16) {
                        productInfo

                        if let description = product.description, !description.isEmpty {
                            descriptionSection(description)
                        }

                        Spacer(minLength: 20)
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100) // espace pour le CTA bas
                }
            }
            .ignoresSafeArea(edges: .top)

            // Bouton "Ajouter au panier" fixé en bas
            bottomAddToCartBar
        }
        // Masquer la barre de navigation pour éviter toute marge en haut
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
        .alert(R.string.localizable.shopAddedToCart(), isPresented: $showAddedToCart) {
            Button(R.string.localizable.commonOk()) {}
        } message: {
            Text(R.string.localizable.shopProductAddedMessage())
        }
    }

    // MARK: - Header Image (plein haut) + Close
    private var headerImageWithClose: some View {
        ZStack(alignment: .topTrailing) {
            // Image qui remplit complètement le haut
            GeometryReader { geometry in
                AsyncImage(url: product.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "car.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                        }
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: geometry.size.width, height: min(UIScreen.main.bounds.height * 0.45, 420))
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.25)],
                        startPoint: .center, endPoint: .bottom
                    )
                )
            }
            .frame(height: min(UIScreen.main.bounds.height * 0.45, 420))
            .ignoresSafeArea(edges: .top)

            // Bouton de fermeture en overlay (coin haut droit)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .padding(.top, 50) // Ajusté pour être sous la status bar
            .padding(.trailing, 20)
            .buttonStyle(.plain)
        }
    }

    // MARK: - Info
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let level = product.level, !level.isEmpty {
                Text(level.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }

            Text(product.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.orange)
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(R.color.primaryText))
                }

                Text("(\(product.reviewCount) \(R.string.localizable.shopReviews()))")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                Text(product.formattedPrice)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(R.color.primaryText))

                if product.promoPrice != nil {
                    Text(String(format: "%.2f €", product.price))
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .strikethrough()
                }
            }

            quantitySelector
        }
    }

    private var quantitySelector: some View {
        HStack {
            Text(R.string.localizable.shopQuantity())
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(R.color.primaryText))

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(quantity > 1 ? .orange : .gray)
                }
                .disabled(quantity <= 1)

                Text("\(quantity)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(R.color.primaryText))
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
        .padding(.top, 6)
    }

    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(R.string.localizable.shopDescription())
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(3)
        }
    }

    // MARK: - Bottom CTA
    private var bottomAddToCartBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black.opacity(0.1))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(R.string.localizable.shopTotal())
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(totalFormatted)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    addToCart()
                    showAddedToCart = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                        Text(R.string.localizable.shopAddToCart())
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(true)
    }

    private var totalFormatted: String {
        let unit = product.promoPrice ?? product.price
        return String(format: "%.2f €", unit * Double(quantity))
    }

    // MARK: - Add to Cart Logic
    private func addToCart() {
        if let existingIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[existingIndex] = CartItem(
                id: cartItems[existingIndex].id,
                product: product,
                quantity: cartItems[existingIndex].quantity + quantity
            )
        } else {
            let newItem = CartItem(
                id: UUID().uuidString,
                product: product,
                quantity: quantity
            )
            cartItems.append(newItem)
        }
    }
}
