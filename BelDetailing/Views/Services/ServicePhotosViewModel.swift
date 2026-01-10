//
//  ServicePhotosViewModel.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

@MainActor
final class ServicePhotosViewModel: ObservableObject {
    @Published var photos: [ServicePhoto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let serviceId: String
    private let engine: Engine
    
    init(serviceId: String, engine: Engine) {
        self.serviceId = serviceId
        self.engine = engine
    }
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        
        let result = await engine.servicePhotoService.getPhotos(serviceId: serviceId)
        
        switch result {
        case .success(let servicePhotos):
            photos = servicePhotos
        case .failure(let error):
            errorMessage = error.localizedDescription
            photos = []
        }
        
        isLoading = false
    }
    
    func deletePhoto(photoId: String) async {
        let result = await engine.servicePhotoService.deletePhoto(serviceId: serviceId, photoId: photoId)
        
        switch result {
        case .success:
            await loadPhotos()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

