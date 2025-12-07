//
//  BookingService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

// MARK: - Protocol

protocol BookingService {
    func getBookings(scope: String?, status: String?) async -> APIResponse<[Booking]>
    func getBookingDetail(id: String) async -> APIResponse<Booking>
    func createBooking(_ data: [String : Any]) async -> APIResponse<CreateBookingResponse>
    func updateBooking(id: String, data: [String: Any]) async -> APIResponse<Booking>
    func cancelBooking(id: String) async -> APIResponse<Bool>
    func confirmBooking(id: String) async -> APIResponse<Bool>
    func declineBooking(id: String) async -> APIResponse<Bool>
    func getAvailableSlots(providerId: String, date: String) async -> APIResponse<[String]>
}


// MARK: - Network Implementation

final class BookingServiceNetwork: BookingService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getBookings(scope: String? = nil,
                     status: String? = nil) async -> APIResponse<[Booking]> {
        await networkClient.call(
            endPoint: .bookingsList(scope: scope, status: status)
        )
    }

    func getBookingDetail(id: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingUpdate(id: id)
        )
    }
    
    func createBooking(_ data: [String : Any]) async -> APIResponse<CreateBookingResponse> {
        print("➡️Booking payload envoyé :", data)

        // 1️⃣Appel RAW qui renvoie du Data brut
        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: .bookingCreate,
            dict: data
        )

        switch raw {
        case .failure(let err):
            print("❌Erreur backend brut :", err)
            return .failure(err)

        case .success(let body):
            do {
                // 2️⃣Décodage custom qui respecte SNAKE_CASE du backend
                let parsed = try CreateBookingResponse.decodeFromBookingResponse(body)
                print("⬅️Réponse création booking :", parsed)
                return .success(parsed)
            } catch {
                print("❌Erreur DECODING custom :", error)
                return .failure(.decodingError(decodingError: error))
            }
        }
    }


    func updateBooking(id: String,
                       data: [String: Any]) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingUpdate(id: id),
            dict: data
        )
    }

    func cancelBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .bookingCancel(id: id)
        )
    }

    func confirmBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .bookingConfirm(id: id)
        )
    }

    func declineBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .bookingDecline(id: id)
        )
    }

    func getAvailableSlots(providerId: String,
                           date: String) async -> APIResponse<[String]> {
        // Exemple futur endpoint:
        // /api/v1/providers/:id/slots?date=2025-12-15
        await networkClient.call(
            endPoint: .providerServices(providerId: providerId),
            urlDict: ["date": date]
        )
    }

}
