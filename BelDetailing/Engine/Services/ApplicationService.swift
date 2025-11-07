//
//  ApplicationService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

protocol ApplicationService {
    func getApplications(forOffer offerId: String) async -> APIResponse<[Application]>
    func apply(toOffer offerId: String, data: [String: Any]) async -> APIResponse<Application>
    func withdrawApplication(id: String) async -> APIResponse<Bool>
    func acceptApplication(id: String) async -> APIResponse<Bool>
    func refuseApplication(id: String) async -> APIResponse<Bool>
}

final class ApplicationServiceNetwork: ApplicationService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getApplications(forOffer offerId: String) async -> APIResponse<[Application]> {
        await networkClient.call(endPoint: .offerApplications(offerId: offerId))
    }

    func apply(toOffer offerId: String, data: [String: Any]) async -> APIResponse<Application> {
        await networkClient.call(endPoint: .offerApply(offerId: offerId), dict: data)
    }

    func withdrawApplication(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .applicationWithdraw(id: id))
    }

    func acceptApplication(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .applicationAccept(id: id))
    }

    func refuseApplication(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .applicationRefuse(id: id))
    }
}

final class ApplicationServiceMock: MockService, ApplicationService {
    func getApplications(forOffer offerId: String) async -> APIResponse<[Application]> {
        await randomWait()
        return .success(Application.sampleValues.filter { $0.offerId == offerId })
    }

    func apply(toOffer offerId: String, data: [String: Any]) async -> APIResponse<Application> {
        await randomWait()
        return .success(Application.sampleValues.first!)
    }

    func withdrawApplication(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }

    func acceptApplication(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }

    func refuseApplication(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
}
