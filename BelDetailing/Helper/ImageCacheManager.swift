//
//  ImageCacheManager.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import UIKit

/// Gestionnaire de cache agressif pour les images
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache: URLCache
    private let memoryCache = NSCache<NSString, UIImage>()
    private let urlSession: URLSession
    
    /// TTL pour le cache (7 jours)
    private let cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    
    private init() {
        // Cache disque : 100 MB
        // Cache mémoire : 50 MB
        let diskCapacity = 100 * 1024 * 1024 // 100 MB
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        
        cache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "image_cache"
        )
        
        // Configurer le cache mémoire
        memoryCache.countLimit = 100 // Max 100 images en mémoire
        memoryCache.totalCostLimit = memoryCapacity
        
        // Configurer URLSession avec cache
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Get Image
    
    /// Récupère une image depuis le cache ou le réseau
    func getImage(from urlString: String, useThumbnail: Bool = true) async -> UIImage? {
        // Construire l'URL (thumbnail ou full)
        let finalUrlString = useThumbnail ? thumbnailUrl(from: urlString) : urlString
        
        guard let url = URL(string: finalUrlString) else {
            return nil
        }
        
        // 1) Vérifier le cache mémoire
        if let cachedImage = memoryCache.object(forKey: finalUrlString as NSString) {
            return cachedImage
        }
        
        // 2) Vérifier le cache disque
        if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)) {
            if let image = UIImage(data: cachedResponse.data) {
                // Mettre en cache mémoire
                memoryCache.setObject(image, forKey: finalUrlString as NSString)
                return image
            }
        }
        
        // 3) Télécharger depuis le réseau avec cache configuré
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Vérifier que c'est une image valide
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Mettre en cache
            let cachedResponse = CachedURLResponse(
                response: response,
                data: data,
                userInfo: ["timestamp": Date().timeIntervalSince1970],
                storagePolicy: .allowed
            )
            cache.storeCachedResponse(cachedResponse, for: request)
            memoryCache.setObject(image, forKey: finalUrlString as NSString)
            
            return image
        } catch {
            print("⚠️ [ImageCache] Failed to load image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Preload
    
    /// Précharge une image en arrière-plan
    func preloadImage(from urlString: String, useThumbnail: Bool = true) {
        Task {
            _ = await getImage(from: urlString, useThumbnail: useThumbnail)
        }
    }
    
    // MARK: - Clear Cache
    
    /// Vide le cache (utile si l'utilisateur manque d'espace)
    func clearCache() {
        cache.removeAllCachedResponses()
        memoryCache.removeAllObjects()
    }
    
    // MARK: - Helper
    
    /// Convertit une URL full en URL thumbnail (si le backend supporte)
    private func thumbnailUrl(from urlString: String) -> String {
        // Si l'URL contient déjà "_thumb", on la retourne telle quelle
        if urlString.contains("_thumb") {
            return urlString
        }
        
        // Sinon, on essaie de construire l'URL thumbnail
        // Format Supabase : https://xxx.supabase.co/storage/v1/object/public/media/xxx.jpg
        // Thumbnail : https://xxx.supabase.co/storage/v1/object/public/media/xxx_thumb.jpg
        
        if let url = URL(string: urlString),
           let lastComponent = url.lastPathComponent.components(separatedBy: ".").first,
           let ext = url.pathExtension.isEmpty ? nil : url.pathExtension {
            let baseUrl = urlString.replacingOccurrences(of: url.lastPathComponent, with: "")
            return "\(baseUrl)\(lastComponent)_thumb.\(ext)"
        }
        
        return urlString
    }
}

