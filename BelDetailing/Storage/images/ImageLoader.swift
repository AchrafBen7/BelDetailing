//
//  ImageLoader.swift
//  BelDetailing
//
//  Created by Achraf Benali on 14/11/2025.
//
import SwiftUI
import Combine

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private static let cache = NSCache<NSString, UIImage>()
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    @MainActor
    func load() async {
        // Pas d’URL -> rien à faire
        guard let url = url else { return }

        // 1. Cache mémoire
        if let cached = Self.cache.object(forKey: url.absoluteString as NSString) {
            self.image = cached
            return
        }

        // 2. Download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data) {
                Self.cache.setObject(img, forKey: url.absoluteString as NSString)
                self.image = img
            }
        } catch {
            print("Image load error:", error)
        }
    }
}
