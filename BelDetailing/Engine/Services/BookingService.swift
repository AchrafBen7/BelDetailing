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
    
    // Service Progress Tracking
    func startService(bookingId: String) async -> APIResponse<Booking>
    func updateProgress(bookingId: String, stepId: String) async -> APIResponse<Booking>
    func completeService(bookingId: String) async -> APIResponse<Booking>
    
    // Counter Proposals
    func counterPropose(bookingId: String, date: String, startTime: String, endTime: String, message: String?) async -> APIResponse<Booking>
    func acceptCounterProposal(bookingId: String) async -> APIResponse<Booking>
    func refuseCounterProposal(bookingId: String) async -> APIResponse<Booking>
    
    // Cleanup expired bookings (>6h pending)
    func cleanupExpiredBookings() async -> APIResponse<Int>
    
    // No-Show Protection
    func reportNoShow(bookingId: String) async -> APIResponse<NoShowResponse>
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
        print("🔵 [BookingService] confirmBooking START")
        print("🔵 [BookingService] confirmBooking - id type: \(type(of: id))")
        print("🔵 [BookingService] confirmBooking - id value: '\(id)'")
        print("🔵 [BookingService] confirmBooking - id isEmpty: \(id.isEmpty)")
        print("🔵 [BookingService] confirmBooking - id count: \(id.count)")
        defer { print("🔵 [BookingService] confirmBooking END") }
        
        // Le backend renvoie { success: true, data: Booking }
        // On utilise callRaw pour éviter les problèmes de décodage automatique
        print("🔵 [BookingService] confirmBooking - Creating endpoint...")
        let endpoint = APIEndPoint.bookingConfirm(id: id)
        print("🔵 [BookingService] confirmBooking - Endpoint created, calling callRaw...")
        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: endpoint
        )
        print("🔵 [BookingService] confirmBooking - callRaw returned")
        
        switch raw {
        case .success(let data):
            print("✅ [BookingService] confirmBooking - Got success response, data size: \(data.count) bytes")
            // Décoder manuellement uniquement le champ "success"
            do {
                print("🔵 [BookingService] confirmBooking - Parsing JSON...")
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                print("🔵 [BookingService] confirmBooking - JSON parsed successfully")
                
                if let json = jsonObject as? [String: Any] {
                    print("🔵 [BookingService] confirmBooking - JSON is dictionary, keys: \(json.keys.joined(separator: ", "))")
                    if let success = json["success"] as? Bool {
                        print("✅ [BookingService] confirmBooking - success = \(success)")
                        return .success(success)
                    } else {
                        print("⚠️ [BookingService] confirmBooking - No 'success' field in JSON, but status 200 - assuming success")
                        return .success(true)
                    }
                } else {
                    print("⚠️ [BookingService] confirmBooking - JSON is not a dictionary, but status 200 - assuming success")
                    return .success(true)
                }
            } catch {
                // Si le JSON est invalide mais qu'on a un status 200, on considère que c'est un succès
                print("⚠️ [BookingService] confirmBooking - JSON decode error: \(error.localizedDescription), but status 200 - assuming success")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔵 [BookingService] confirmBooking - Raw JSON (first 500 chars): \(String(jsonString.prefix(500)))")
                }
                return .success(true)
            }
        case .failure(let err):
            print("❌ [BookingService] confirmBooking - Error: \(err.localizedDescription)")
            return .failure(err)
        }
    }

    func declineBooking(id: String) async -> APIResponse<Bool> {
        print("🔵 [BookingService] declineBooking START")
        print("🔵 [BookingService] declineBooking - id type: \(type(of: id))")
        print("🔵 [BookingService] declineBooking - id value: '\(id)'")
        print("🔵 [BookingService] declineBooking - id isEmpty: \(id.isEmpty)")
        print("🔵 [BookingService] declineBooking - id count: \(id.count)")
        defer { print("🔵 [BookingService] declineBooking END") }
        
        // Le backend renvoie { success: true, data: Booking }
        // On utilise callRaw pour éviter les problèmes de décodage automatique
        print("🔵 [BookingService] declineBooking - Creating endpoint...")
        let endpoint = APIEndPoint.bookingDecline(id: id)
        print("🔵 [BookingService] declineBooking - Endpoint created, calling callRaw...")
        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: endpoint
        )
        print("🔵 [BookingService] declineBooking - callRaw returned")
        
        switch raw {
        case .success(let data):
            print("✅ [BookingService] declineBooking - Got success response, data size: \(data.count) bytes")
            // Décoder manuellement uniquement le champ "success"
            do {
                print("🔵 [BookingService] declineBooking - Parsing JSON...")
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                print("🔵 [BookingService] declineBooking - JSON parsed successfully")
                
                if let json = jsonObject as? [String: Any] {
                    print("🔵 [BookingService] declineBooking - JSON is dictionary, keys: \(json.keys.joined(separator: ", "))")
                    if let success = json["success"] as? Bool {
                        print("✅ [BookingService] declineBooking - success = \(success)")
                        return .success(success)
                    } else {
                        print("⚠️ [BookingService] declineBooking - No 'success' field in JSON, but status 200 - assuming success")
                        return .success(true)
                    }
                } else {
                    print("⚠️ [BookingService] declineBooking - JSON is not a dictionary, but status 200 - assuming success")
                    return .success(true)
                }
            } catch {
                // Si le JSON est invalide mais qu'on a un status 200, on considère que c'est un succès
                print("⚠️ [BookingService] declineBooking - JSON decode error: \(error.localizedDescription), but status 200 - assuming success")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔵 [BookingService] declineBooking - Raw JSON (first 500 chars): \(String(jsonString.prefix(500)))")
                }
                return .success(true)
            }
        case .failure(let err):
            print("❌ [BookingService] declineBooking - Error: \(err.localizedDescription)")
            return .failure(err)
        }
    }

    func getAvailableSlots(providerId: String,
                           date: String) async -> APIResponse<[String]> {
        await networkClient.call(
            endPoint: .providerServices(providerId: providerId),
            urlDict: ["date": date]
        )
    }
    
    // MARK: - Service Progress Tracking
    
    func startService(bookingId: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingStartService(id: bookingId),
            wrappedInData: true
        )
    }
    
    func updateProgress(bookingId: String, stepId: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingUpdateProgress(id: bookingId),
            dict: ["step_id": stepId],
            wrappedInData: true
        )
    }
    
    func completeService(bookingId: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingCompleteService(id: bookingId),
            wrappedInData: true
        )
    }
    
    // MARK: - Counter Proposals
    
    func counterPropose(bookingId: String, date: String, startTime: String, endTime: String, message: String?) async -> APIResponse<Booking> {
        var payload: [String: Any] = [
            "date": date,
            "start_time": startTime,
            "end_time": endTime
        ]
        if let message = message, !message.isEmpty {
            payload["message"] = message
        }
        return await networkClient.call(
            endPoint: .bookingCounterPropose(id: bookingId),
            dict: payload,
            wrappedInData: true
        )
    }
    
    func acceptCounterProposal(bookingId: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingAcceptCounterProposal(id: bookingId),
            wrappedInData: true
        )
    }
    
    func refuseCounterProposal(bookingId: String) async -> APIResponse<Booking> {
        await networkClient.call(
            endPoint: .bookingRefuseCounterProposal(id: bookingId),
            wrappedInData: true
        )
    }
    
    // MARK: - No-Show Protection
    
    func reportNoShow(bookingId: String) async -> APIResponse<NoShowResponse> {
        return await networkClient.call(
            endPoint: .bookingReportNoShow(id: bookingId)
        )
    }
    
    // MARK: - Cleanup Expired Bookings
    
    func cleanupExpiredBookings() async -> APIResponse<Int> {
        print("🧹 [BookingService] cleanupExpiredBookings START")
        let raw: APIResponse<Data> = await networkClient.callRaw(
            endPoint: .bookingCleanupExpired
        )
        
        switch raw {
        case .success(let data):
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                if let json = jsonObject as? [String: Any],
                   let deletedCount = json["deleted_count"] as? Int {
                    print("✅ [BookingService] cleanupExpiredBookings - Deleted \(deletedCount) expired bookings")
                    return .success(deletedCount)
                } else if let json = jsonObject as? [String: Any],
                          let count = json["count"] as? Int {
                    print("✅ [BookingService] cleanupExpiredBookings - Deleted \(count) expired bookings")
                    return .success(count)
                } else {
                    print("⚠️ [BookingService] cleanupExpiredBookings - No count in response, assuming 0")
                    return .success(0)
                }
            } catch {
                print("⚠️ [BookingService] cleanupExpiredBookings - JSON decode error: \(error.localizedDescription)")
                return .success(0) // On considère que c'est OK même si on ne peut pas parser
            }
        case .failure(let err):
            print("❌ [BookingService] cleanupExpiredBookings - Error: \(err.localizedDescription)")
            return .failure(err)
        }
    }
}

