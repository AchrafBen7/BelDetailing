//
//  LoadingView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

/// Vue de chargement de base
struct LoadingView: View {
    var message: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            } else {
                Text(R.string.localizable.loaderDescription())
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}

/// Vue de chargement avec skeleton (pour les listes)
struct SkeletonLoadingView: View {
    let itemCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<itemCount, id: \.self) { _ in
                SkeletonCard()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

/// Carte skeleton pour les listes avec effet shimmer
private struct SkeletonCard: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 0) {
            // Image skeleton
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    ShimmerEffect()
                        .offset(x: shimmerOffset)
                )
                .clipped()
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .frame(width: 200)
                    .overlay(
                        ShimmerEffect()
                            .offset(x: shimmerOffset)
                    )
                    .clipped()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 16)
                    .frame(width: 150)
                    .overlay(
                        ShimmerEffect()
                            .offset(x: shimmerOffset)
                    )
                    .clipped()
                
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 14)
                        .frame(width: 100)
                        .overlay(
                            ShimmerEffect()
                                .offset(x: shimmerOffset)
                        )
                        .clipped()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 14)
                        .frame(width: 80)
                        .overlay(
                            ShimmerEffect()
                                .offset(x: shimmerOffset)
                        )
                        .clipped()
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ShimmerEffect()
                                .offset(x: shimmerOffset)
                        )
                        .clipped()
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ShimmerEffect()
                                .offset(x: shimmerOffset)
                        )
                        .clipped()
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 400
            }
        }
    }
}

/// Effet shimmer pour les skeletons
private struct ShimmerEffect: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.0),
                Color.white.opacity(0.3),
                Color.white.opacity(0.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 200)
    }
}

/// Vue de chargement inline (pour les boutons)
struct InlineLoadingView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text(R.string.localizable.commonLoading())
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }
}

#Preview { 
    VStack {
        LoadingView()
        SkeletonLoadingView(itemCount: 3)
    }
}
