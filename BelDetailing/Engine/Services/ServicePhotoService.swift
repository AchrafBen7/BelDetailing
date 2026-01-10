//
//  ServicePhotoService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation

protocol ServicePhotoService {
    func getPhotos(serviceId: String) async -> APIResponse<[ServicePhoto]>
    func addPhoto(serviceId: String, imageUrl: String, caption: String?) async -> APIResponse<ServicePhoto>
    func deletePhoto(serviceId: String, photoId: String) async -> APIResponse<Bool>
}

final class ServicePhotoServiceNetwork: ServicePhotoService {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getPhotos(serviceId: String) async -> APIResponse<[ServicePhoto]> {
        await networkClient.call(endPoint: .servicePhotos(serviceId: serviceId))
    }
    
    func addPhoto(serviceId: String, imageUrl: String, caption: String?) async -> APIResponse<ServicePhoto> {
        var payload: [String: Any] = [
            "image_url": imageUrl
        ]
        
        if let caption, !caption.isEmpty {
            payload["caption"] = caption
        }
        
        return await networkClient.call(
            endPoint: .servicePhotoAdd(serviceId: serviceId),
            dict: payload
        )
    }
    
    func deletePhoto(serviceId: String, photoId: String) async -> APIResponse<Bool> {
        let response: APIResponse<EmptyResponse> = await networkClient.call(
            endPoint: .servicePhotoDelete(serviceId: serviceId, photoId: photoId)
        )
        
        switch response {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
}
