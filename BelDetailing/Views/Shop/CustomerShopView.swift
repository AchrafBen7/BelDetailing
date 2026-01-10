import SwiftUI
import Foundation
import RswiftResources

// Tri disponible dans la boutique
private enum SortOption: String, CaseIterable, Identifiable {
    case popularity
    case priceLowToHigh
    case priceHighToLow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .popularity: return "Popularité"
        case .priceLowToHigh: return "Prix: croissant"
        case .priceHighToLow: return "Prix: décroissant"
        }
    }
}

struct CustomerShopView: View {
    let engine: Engine
    @StateObject private var viewModel: CustomerShopViewModel
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .popularity
    @State private var cartItems: [CartItem] = []
    @State private var selectedProduct: Product?

    init(engine: Engine) {
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CustomerShopViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(R.color.mainBackground.name).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header
                        searchAndSortBar
                        categoryFilters

                        // Produits (filtrés + triés)
                        productsGrid
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }

                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.load() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("Boutique.")
                .textView(style: .heroTitle)

            Spacer()

            NavigationLink {
                CartView(engine: engine, cartItems: $cartItems)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.black)
                        .padding(6)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                    
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
    }

    // MARK: - Barre recherche + tri
    private var searchAndSortBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un produit", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08), lineWidth: 1))

                Menu {
                    Picker("Tri", selection: $sortOption) {
                        ForEach(SortOption.allCases) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.title)
                            .lineLimit(1)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08), lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Filtres catégories (chips)
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryChip(nil, title: "Tout")

                ForEach(ProductCategory.allCases, id: \.self) { cat in
                    categoryChip(cat, title: cat.localizedTitle)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func categoryChip(_ cat: ProductCategory?, title: String) -> some View {
        let isSelected = viewModel.selectedCategory == cat
        return Button {
            viewModel.selectedCategory = cat
            Task { await viewModel.loadProducts() }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.black : Color.white)
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(isSelected ? 0 : 0.15), lineWidth: 1)
                )
                .shadow(color: isSelected ? .black.opacity(0.15) : .clear, radius: 6, y: 3)
        }
    }

    // MARK: - Grille produits
    private var productsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tous les produits")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))
                .padding(.horizontal, 20)

            Group {
                if viewModel.isLoading && filteredAndSortedProducts.isEmpty {
                    ProgressView().padding(.top, 12)
                } else if filteredAndSortedProducts.isEmpty {
                    ShopEmptyStateView(
                        title: "Aucun produit",
                        message: "Ajustez vos filtres pour découvrir plus d’articles."
                    )
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredAndSortedProducts, id: \.id) { product in
                            NavigationLink {
                                ProductDetailView(
                                    product: product,
                                    engine: engine,
                                    cartItems: $cartItems
                                )
                            } label: {
                                ShopProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }


    // MARK: - Filtrage + tri côté client (noms explicites pour SwiftLint)
    private var filteredAndSortedProducts: [Product] {
        // 1) Filtre par recherche
        let base: [Product] = {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !query.isEmpty else { return viewModel.products }
            return viewModel.products.filter { product in
                product.name.lowercased().contains(query)
                || (product.description?.lowercased().contains(query) ?? false)
                || product.category.localizedTitle.lowercased().contains(query)
            }
        }()

        // 2) Tri explicite
        switch sortOption {
        case .popularity:
            // Tri par note puis par nombre d'avis
            return base.sorted(by: { (lhs: Product, rhs: Product) -> Bool in
                if lhs.rating == rhs.rating {
                    return lhs.reviewCount > rhs.reviewCount
                } else {
                    return lhs.rating > rhs.rating
                }
            })

        case .priceLowToHigh:
            return base.sorted(by: { (lhs: Product, rhs: Product) -> Bool in
                let leftPrice = lhs.promoPrice ?? lhs.price
                let rightPrice = rhs.promoPrice ?? rhs.price
                return leftPrice < rightPrice
            })

        case .priceHighToLow:
            return base.sorted(by: { (lhs: Product, rhs: Product) -> Bool in
                let leftPrice = lhs.promoPrice ?? lhs.price
                let rightPrice = rhs.promoPrice ?? rhs.price
                return leftPrice > rightPrice
            })
        }
    }
}

// MARK: - Empty state (renommée pour éviter collisions)
private struct ShopEmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - ShopProductCard (locale pour éviter d'utiliser une vue privée d'un autre fichier)
private struct ShopProductCard: View {
    let product: Product

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: product.imageURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .empty: Color.gray.opacity(0.15)
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "car.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                @unknown default: Color.gray.opacity(0.15)
                }
            }
            .frame(height: 192)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.75)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", product.rating))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))

                    Text("(\(product.reviewCount))")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))

                    Spacer(minLength: 8)

                    Text(product.formattedPrice)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    if let promo = product.formattedPromoPrice {
                        Text(promo)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .strikethrough()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}
