//
//  OfferService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//


import Foundation

protocol OfferService {
    func getOffers(status: OfferStatus?, type: OfferType?) async -> APIResponse<[Offer]>
    func getOfferDetail(id: String) async -> APIResponse<Offer>
    func createOffer(_ data: [String: Any]) async -> APIResponse<Offer>
    func updateOffer(id: String, data: [String: Any]) async -> APIResponse<Offer>
    func closeOffer(id: String) async -> APIResponse<Bool>
    func deleteOffer(id: String) async -> APIResponse<Bool>
}

final class OfferServiceNetwork: OfferService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getOffers(status: OfferStatus? = nil, type: OfferType? = nil) async -> APIResponse<[Offer]> {
        await networkClient.call(
            endPoint: .offersList,
            urlDict: [
                "status": status?.rawValue,
                "type": type?.rawValue
            ],
            wrappedInData: true
        )
    }

    func getOfferDetail(id: String) async -> APIResponse<Offer> {
        await networkClient.call(
            endPoint: .offerDetail(id: id),
            wrappedInData: true
        )
    }

    func createOffer(_ data: [String: Any]) async -> APIResponse<Offer> {
        // data verwacht o.a.: title, category, description, vehicleCount, priceMin, priceMax, city, postalCode, type, attachments[]
        await networkClient.call(
            endPoint: .offerCreate,
            dict: data,
            wrappedInData: true
        )
    }

    func updateOffer(id: String, data: [String: Any]) async -> APIResponse<Offer> {
        await networkClient.call(
            endPoint: .offerUpdate(id: id),
            dict: data,
            wrappedInData: true
        )
    }

    func closeOffer(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .offerClose(id: id),
            wrappedInData: true
        )
    }

    func deleteOffer(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .offerDelete(id: id),
            wrappedInData: true
        )
    }
}
