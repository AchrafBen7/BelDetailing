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
    func createBooking(_ data: [String: Any]) async -> APIResponse<Booking>
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
    func getBookings(scope: String? = nil, status: String? = nil) async -> APIResponse<[Booking]> {
        await networkClient.call(endPoint: .bookingsList(scope: scope, status: status))
    }
    func getBookingDetail(id: String) async -> APIResponse<Booking> {
        await networkClient.call(endPoint: .bookingUpdate(id: id))
    }
    func createBooking(_ data: [String: Any]) async -> APIResponse<Booking> {
        await networkClient.call(endPoint: .bookingCreate, dict: data)
    }
    func updateBooking(id: String, data: [String: Any]) async -> APIResponse<Booking> {
        await networkClient.call(endPoint: .bookingUpdate(id: id), dict: data)
    }
    func cancelBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .bookingCancel(id: id))
    }
    func confirmBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .bookingConfirm(id: id))
    }
    func declineBooking(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .bookingDecline(id: id))
    }
    func getAvailableSlots(providerId: String, date: String) async -> APIResponse<[String]> {
        // Exemple futur endpoint: /api/v1/providers/:id/slots?date=2025-12-15
        await networkClient.call(endPoint: .providerServices(providerId: providerId), urlDict: ["date": date])
    }
}

// MARK: - Mock Implementation
final class BookingServiceMock: MockService, BookingService {
    func getBookings(scope: String?, status: String?) async -> APIResponse<[Booking]> {
        await randomWait()
        return .success(Booking.sampleValues)
    }
    func getBookingDetail(id: String) async -> APIResponse<Booking> {
        await randomWait()
        guard let booking = Booking.sampleValues.first(where: { $0.id == id }) else {
            return .failure(.serverError(statusCode: 404))
        }
        return .success(booking)
    }
    func createBooking(_ data: [String: Any]) async -> APIResponse<Booking> {
        await randomWait()
        return .success(Booking.sampleValues.first!)
    }
    func updateBooking(id: String, data: [String: Any]) async -> APIResponse<Booking> {
        await randomWait()
        return .success(Booking.sampleValues.first!)
    }
    func cancelBooking(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
    func confirmBooking(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
    func declineBooking(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
    func getAvailableSlots(providerId: String, date: String) async -> APIResponse<[String]> {
        await randomWait()
        return .success(["09:00", "11:00", "13:30", "15:00", "17:00"])
    }
}
