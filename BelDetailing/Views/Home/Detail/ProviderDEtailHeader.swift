//
//  ProviderDEtailHeader.swift
//
//  Created by Achraf Benali on 17/11/2025.
//  Updated: Carousel avec swipe pour banner + photos portfolio
//

import SwiftUI
import RswiftResources

struct DetailerDetailHeaderView: View {
    let detailer: Detailer
    let portfolioPhotos: [PortfolioPhoto]
    let onPhotoTap: (PortfolioPhoto) -> Void
    
    @State private var currentIndex: Int = 0
    
    init(detailer: Detailer, portfolioPhotos: [PortfolioPhoto] = [], onPhotoTap: @escaping (PortfolioPhoto) -> Void = { _ in }) {
        self.detailer = detailer
        self.portfolioPhotos = portfolioPhotos
        self.onPhotoTap = onPhotoTap
    }
    
    // Toutes les images (banner + portfolio)
    private var allImages: [HeaderImageItem] {
        var items: [HeaderImageItem] = []
        
        // Banner en premier
        if let bannerUrl = detailer.bannerURL {
            items.append(.banner(url: bannerUrl))
        }
        
        // Photos du portfolio ensuite
        items.append(contentsOf: portfolioPhotos.map { .portfolio(photo: $0) })
        
        return items
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // --- CAROUSEL (Banner + Portfolio Photos) ---
            if !allImages.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(Array(allImages.enumerated()), id: \.offset) { index, item in
                        headerImageItem(item: item, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 300)
                .onTapGesture {
                    // Si c'est une photo portfolio, ouvrir en plein écran
                    if case .portfolio(let photo) = allImages[currentIndex] {
                        onPhotoTap(photo)
                    }
                }
            } else {
                // Fallback si pas d'images
                Color.black.opacity(0.2)
                    .frame(height: 300)
            }
            
            // Gradient overlay pour le texte
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            // --- INFORMATIONS DU DETAILER ---
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                
                // Display Name
                Text(detailer.displayName)
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(.white)
                
                // Description (Bio)
                if let bio = detailer.bio, !bio.isEmpty {
                    Text(bio)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                // Rating et Location
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Rating
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                        Text(String(format: "%.1f", detailer.rating))
                            .foregroundColor(.white)
                            .font(DesignSystem.Typography.bodyBold)
                        
                        Text("(\(detailer.reviewCount) avis)")
                            .foregroundColor(.white.opacity(0.8))
                            .font(DesignSystem.Typography.caption)
                    }
                    
                    // Location
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.white.opacity(0.85))
                            .font(.system(size: 14))
                        Text("\(detailer.city), \(detailer.postalCode)")
                            .foregroundColor(.white.opacity(0.9))
                            .font(DesignSystem.Typography.caption)
                    }
                }
                
                // Mobile Service Badge
                if detailer.hasMobileService {
                    Text(R.string.localizable.detailMobileService())
                        .font(DesignSystem.Typography.caption)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipped()
    }
    
    // MARK: - Header Image Item
    
    @ViewBuilder
    private func headerImageItem(item: HeaderImageItem, index: Int) -> some View {
        switch item {
        case .banner(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Color.black.opacity(0.2)
                @unknown default:
                    Color.black.opacity(0.2)
                }
            }
            .frame(height: 300)
            .clipped()
            
        case .portfolio(let photo):
            CachedAsyncImage(
                urlString: photo.imageUrl,
                useThumbnail: false
            ) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
                    .overlay(ProgressView().tint(.white))
            }
            .frame(height: 300)
            .clipped()
        }
    }
}

// MARK: - Header Image Item Enum

private enum HeaderImageItem {
    case banner(url: URL)
    case portfolio(photo: PortfolioPhoto)
}
