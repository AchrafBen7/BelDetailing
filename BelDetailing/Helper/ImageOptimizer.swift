//
//  ImageOptimizer.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import UIKit

/// Service pour optimiser les images avant upload (compression + resize)
final class ImageOptimizer {
    
    /// Qualité JPEG pour thumbnails (plus compressé)
    static let thumbnailQuality: CGFloat = 0.7
    
    /// Qualité JPEG pour images full (moins compressé)
    static let fullQuality: CGFloat = 0.8
    
    /// Largeur max pour thumbnails
    static let thumbnailMaxWidth: CGFloat = 800
    
    /// Largeur max pour images full
    static let fullMaxWidth: CGFloat = 2000
    
    /// Taille max thumbnail en KB (target)
    static let thumbnailMaxSizeKB: Int = 400
    
    /// Taille max full en KB (target)
    static let fullMaxSizeKB: Int = 2000
    
    // MARK: - Generate Thumbnail
    
    /// Génère une version thumbnail optimisée (200-400 KB)
    static func generateThumbnail(from image: UIImage) -> Data? {
        return optimizeImage(
            image: image,
            maxWidth: thumbnailMaxWidth,
            quality: thumbnailQuality,
            targetSizeKB: thumbnailMaxSizeKB
        )
    }
    
    // MARK: - Generate Full
    
    /// Génère une version full optimisée (1-2 MB)
    static func generateFull(from image: UIImage) -> Data? {
        return optimizeImage(
            image: image,
            maxWidth: fullMaxWidth,
            quality: fullQuality,
            targetSizeKB: fullMaxSizeKB
        )
    }
    
    // MARK: - Core Optimization
    
    private static func optimizeImage(
        image: UIImage,
        maxWidth: CGFloat,
        quality: CGFloat,
        targetSizeKB: Int
    ) -> Data? {
        // 1) Resize si nécessaire
        let resizedImage = resizeImage(image: image, maxWidth: maxWidth)
        
        // 2) Convertir en JPEG avec qualité
        guard let jpegData = resizedImage.jpegData(compressionQuality: quality) else {
            return nil
        }
        
        // 3) Si trop gros, réduire la qualité progressivement
        var finalData = jpegData
        var currentQuality = quality
        
        while finalData.count > targetSizeKB * 1024 && currentQuality > 0.3 {
            currentQuality -= 0.1
            if let newData = resizedImage.jpegData(compressionQuality: currentQuality) {
                finalData = newData
            } else {
                break
            }
        }
        
        return finalData
    }
    
    // MARK: - Resize
    
    private static func resizeImage(image: UIImage, maxWidth: CGFloat) -> UIImage {
        let size = image.size
        
        // Si l'image est déjà plus petite, pas besoin de resize
        if size.width <= maxWidth {
            return image
        }
        
        // Calculer la nouvelle taille en gardant le ratio
        let ratio = maxWidth / size.width
        let newHeight = size.height * ratio
        let newSize = CGSize(width: maxWidth, height: newHeight)
        
        // Redessiner l'image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - File Names
    
    static func generateThumbnailFileName(originalName: String) -> String {
        let nameWithoutExt = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        return "\(nameWithoutExt)_thumb.\(ext)"
    }
    
    static func generateFullFileName(originalName: String) -> String {
        let nameWithoutExt = (originalName as NSString).deletingPathExtension
        let ext = (originalName as NSString).pathExtension
        return "\(nameWithoutExt)_full.\(ext)"
    }
}

