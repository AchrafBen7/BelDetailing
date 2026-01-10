//
//  OptimizedImageUploader.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import UIKit

/// Service pour uploader des images optimisées (thumbnail + full)
final class OptimizedImageUploader {
    let mediaService: MediaService
    
    init(mediaService: MediaService) {
        self.mediaService = mediaService
    }
    
    /// Upload une image avec génération automatique de thumbnail et full
    /// Retourne les URLs (thumbnail + full)
    func uploadOptimizedImage(
        image: UIImage,
        originalFileName: String = "photo.jpg"
    ) async -> APIResponse<UploadedImageURLs> {
        // 1) Générer les versions optimisées
        guard let thumbnailData = ImageOptimizer.generateThumbnail(from: image),
              let fullData = ImageOptimizer.generateFull(from: image) else {
            let err = NSError(
                domain: "OptimizedImageUploader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to optimize image"]
            )
            return .failure(.from(error: err))
        }
        
        // 2) Upload thumbnail
        let thumbnailFileName = ImageOptimizer.generateThumbnailFileName(originalName: originalFileName)
        let thumbnailResult = await mediaService.uploadFile(
            data: thumbnailData,
            fileName: thumbnailFileName,
            mimeType: "image/jpeg"
        )
        
        guard case let .success(thumbnailAttachment) = thumbnailResult else {
            if case let .failure(error) = thumbnailResult {
                return .failure(error)
            }
            let err = NSError(
                domain: "OptimizedImageUploader",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to upload thumbnail"]
            )
            return .failure(.from(error: err))
        }
        
        // 3) Upload full
        let fullFileName = ImageOptimizer.generateFullFileName(originalName: originalFileName)
        let fullResult = await mediaService.uploadFile(
            data: fullData,
            fileName: fullFileName,
            mimeType: "image/jpeg"
        )
        
        guard case let .success(fullAttachment) = fullResult else {
            if case let .failure(error) = fullResult {
                return .failure(error)
            }
            let err = NSError(
                domain: "OptimizedImageUploader",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to upload full image"]
            )
            return .failure(.from(error: err))
        }
        
        let urls = UploadedImageURLs(
            thumbnailUrl: thumbnailAttachment.url,
            fullUrl: fullAttachment.url
        )
        return .success(urls)
    }
}
