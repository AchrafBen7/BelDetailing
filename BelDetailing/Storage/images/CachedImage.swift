//
//  CachedImage.swift
//  BelDetailing
//
//  Created by Achraf Benali on 14/11/2025.
//
import SwiftUI
import Combine

struct CachedImage: View {
    @StateObject private var loader: ImageLoader
    private let cornerRadius: CGFloat

    init(url: URL?, cornerRadius: CGFloat = 0) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .task { await loader.load() }
    }
}
