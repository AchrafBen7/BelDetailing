import SwiftUI
import Combine
import RswiftResources
import SafariServices

struct CustomerDashboardView: View {
    let engine: Engine
    @StateObject private var vm: CustomerDashboardViewModel

    @State private var safariURL: URL?

    init(engine: Engine) {
        self.engine = engine
        _vm = StateObject(wrappedValue: CustomerDashboardViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    categoryFilters
                    recommendedSection
                    productsGrid
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color(R.color.mainBackground.name))
            // .navigationTitle("Boutique") // supprimé pour éviter la duplication
            .toolbarTitleDisplayMode(.inline)
        }
        .task { await vm.load() }
        .sheet(isPresented: .constant(safariURL != nil), onDismiss: { safariURL = nil }) {
            if let url = safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Header “Boutique” + avatar
    private var header: some View {
        HStack {
            Text("Boutique")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))

            Spacer()

            // Icône "lightbulb" en noir et un peu plus petite
            Image(systemName: "lightbulb")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.black)
                .padding(6)
                .background(Color.black.opacity(0.05))
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
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
        let isSelected = vm.selectedCategory == cat
        return Button {
            vm.selectedCategory = cat
            Task { await vm.loadProducts() }
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

    // MARK: - Recommandés pour vous (agrandies ++)
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Recommandés pour vous")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(R.color.primaryText))
                Spacer()
                // Optionnel: “Voir tout”
                Text("Voir tout")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)

            Group {
                if vm.isLoadingProducts && vm.recommendedProducts.isEmpty {
                    ProgressView().padding(.top, 12)
                } else if vm.recommendedProducts.isEmpty {
                    EmptyStateView(
                        title: "Aucune recommandation",
                        message: "Nous vous proposerons bientôt des produits adaptés."
                    )
                    .padding(.horizontal, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(vm.recommendedProducts, id: \.id) { product in
                                CompactProductCard(product: product) {
                                    handleProductTap(product)
                                }
                                .frame(width: 260) // encore plus large pour "Recommandés"
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    }
                }
            }
        }
    }

    // MARK: - Tous les produits: inchangé
    private var productsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tous les produits")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))
                .padding(.horizontal, 20)

            Group {
                if vm.isLoadingProducts && vm.products.isEmpty {
                    ProgressView().padding(.top, 12)
                } else if vm.products.isEmpty {
                    EmptyStateView(
                        title: "Aucun produit",
                        message: "Ajustez vos filtres pour découvrir plus d’articles."
                    )
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 16) {
                        ForEach(vm.products, id: \.id) { product in
                            ProductCardView(
                                product: product,
                                onTap: { handleProductTap(product) }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tap produit → tracking + ouverture lien affilié
    private func handleProductTap(_ product: Product) {
        Task {
            await vm.trackProductClick(product.id)
            if let url = product.affiliateURL {
                await MainActor.run {
                    safariURL = url
                }
            }
        }
    }
}

// MARK: - UI helpers (existants)
private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(Color(R.color.primaryText))
    }
}

private struct BookingRowView: View {
    let booking: Booking
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.displayServiceName)
                    .font(.system(size: 16, weight: .semibold))
                Text("\(booking.date) • \(booking.displayStartTime)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - ProductCard (grande carte pour “Tous les produits”)
private struct ProductCardView: View {
    let product: Product
    var onTap: () -> Void

    init(product: Product, onTap: @escaping () -> Void) {
        self.product = product
        self.onTap = onTap
    }

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
        .onTapGesture { onTap() }
    }
}

// MARK: - CompactProductCard (rectangulaire, compact pour “Recommandés pour vous”)
private struct CompactProductCard: View {
    let product: Product
    var onTap: () -> Void

    init(product: Product, onTap: @escaping () -> Void) {
        self.product = product
        self.onTap = onTap
    }

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
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                @unknown default: Color.gray.opacity(0.15)
                }
            }
            .frame(height: 176) // 160 -> 176
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 108) // 96 -> 108 pour meilleure lisibilité
            .frame(maxWidth: .infinity, alignment: .bottom)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))

                    Text("(\(product.reviewCount))")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))

                    Spacer(minLength: 6)

                    Text(product.formattedPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    if let promo = product.formattedPromoPrice {
                        Text(promo)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.85))
                            .strikethrough()
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        .onTapGesture { onTap() }
    }
}

