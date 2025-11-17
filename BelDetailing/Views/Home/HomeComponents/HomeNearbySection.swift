//
//  HomeNearbySection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI

struct HomeNearbySection: View {
    let title: String
    let providers: [Detailer] // hetzelfde type als vm.recommended
    var onSelect: (Detailer) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(providers) { provider in
                        ProviderCardHorizontal(provider: provider)
                            .onTapGesture {
                                onSelect(provider)        // 👈 NAVIGATION
                            }
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .padding(.bottom, 8)
            }
        }
    }
}
