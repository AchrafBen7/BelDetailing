//
//  CachedAsyncImage.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

/// AsyncImage avec cache agressif et support thumbnail/full
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let urlString: String?
    let useThumbnail: Bool
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    
    init(
        urlString: String?,
        useThumbnail: Bool = true,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.useThumbnail = useThumbnail
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let urlString = urlString else { return }
        
        let image = await ImageCacheManager.shared.getImage(
            from: urlString,
            useThumbnail: useThumbnail
        )
        
        await MainActor.run {
            loadedImage = image
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(urlString: String?, useThumbnail: Bool = true) {
        self.init(
            urlString: urlString,
            useThumbnail: useThumbnail,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

