//
//  MediaService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//


import Foundation

protocol MediaService {
    func uploadFile(data: Data, fileName: String, mimeType: String) async -> APIResponse<Attachment>
    func deleteFile(id: String) async -> APIResponse<Bool>
}

final class MediaServiceNetwork: MediaService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func uploadFile(data: Data, fileName: String, mimeType: String) async -> APIResponse<Attachment> {
        await networkClient.call(endPoint: .mediaUpload, fileData: data, fileName: fileName, mimeType: mimeType)
    }

    func deleteFile(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .mediaDelete(id: id))
    }
}

final class MediaServiceMock: MockService, MediaService {
    func uploadFile(data: Data, fileName: String, mimeType: String) async -> APIResponse<Attachment> {
        await randomWait()
        return .success(
            Attachment(id: "mock_001", fileName: fileName, url: "https://cdn.example.com/\(fileName)", mimeType: mimeType, sizeBytes: data.count)
        )
    }

    func deleteFile(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
}
