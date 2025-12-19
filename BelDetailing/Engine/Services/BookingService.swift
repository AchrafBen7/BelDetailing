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
        print("🛰️ [Service] getBookings(scope:\(scope ?? "nil"), status:\(status ?? "nil")) wrappedInData:true")
        let resp: APIResponse<[Booking]> = await networkClient.call(
            endPoint: .bookingsList(scope: scope, status: status),
            urlDict: nil,
            additionalHeaders: nil,
            timeout: 60,
            allowAutoRefresh: true,
            wrappedInData: true   // ⬅️ CRUCIAL: la réponse est { "data": [...] }
        )
        switch resp {
        case .success(let list):
            print("✅ [Service] decoded bookings count:", list.count)
            if let first = list.first {
                print("ℹ️ [Service] first booking:", first.id, first.status.rawValue, first.date, first.startTime)
            }
        case .failure(let err):
            print("❌ [Service] error:", err)
        }
        return resp
    }

    func getBookingDetail(id: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingUpdate(id: id)
        )
    }
    
    func createBooking(_ data: [String : Any]) async -> APIResponse<CreateBookingResponse> {
        print("➡️ [Service] createBooking payload:", data)

        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: .bookingCreate,
            dict: data
        )

        switch raw {
        case .failure(let err):
            print("❌ [Service] raw error:", err)
            return .failure(err)

        case .success(let body):
            do {
                let parsed = try CreateBookingResponse.decodeFromBookingResponse(body)
                print("⬅️ [Service] createBooking parsed:", parsed)
                return .success(parsed)
            } catch {
                print("❌ [Service] custom DECODING error:", error)
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
        await networkClient.call(
            endPoint: .providerServices(providerId: providerId),
            urlDict: ["date": date]
        )
    }
}
