//
//  HomeAllProvidersSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI
import RswiftResources

struct HomeAllProvidersSection: View {
    let title: String
    let providers: [Detailer]
    var onShowAll: () -> Void = {}
    var onSelect: (Detailer) -> Void = { _ in }
    
    // Pagination
    @State private var visibleCount: Int = 4
    private let batchSize: Int = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyle.Padding.small16.rawValue) {
            // === Header ===
            HStack {
                Text(title)
                    .font(AppStyle.TextStyle.sectionTitle.font)
                    .foregroundColor(AppStyle.TextStyle.sectionTitle.defaultColor)
                Spacer()
                Button(action: onShowAll) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            
            // === Liste verticale (lazy) ===
            LazyVStack(spacing: AppStyle.Padding.small16.rawValue) {
                ForEach(providers.prefix(visibleCount)) { provider in
                    ProviderCardVertical(provider: provider)
                        .onTapGesture {
                            onSelect(provider)             // 👈 NAVIGATION
                        }
                        .onAppear {
                            // charge le lot suivant quand on arrive au dernier
                            
                            if provider == providers.prefix(visibleCount).last,
                               visibleCount < providers.count {
                                loadMore()
                            }
                        }
                }
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        }
        .padding(.bottom, AppStyle.Padding.big32.rawValue)
    }
    
    private func loadMore() {
        withAnimation(.easeInOut) {
            visibleCount = min(visibleCount + batchSize, providers.count)
        }
    }
}
