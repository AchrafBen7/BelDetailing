import UIKit
import StripePaymentSheet
import RswiftResources
import CoreLocation

extension BookingStep3View {

    @MainActor
    func startPaymentFlow() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }

        let transportFee = calculatedTransportFee
        let (transportDistanceKm, customerAddressLat, customerAddressLng) = await geocodeAddressAndCalculateDistance()
        let (totalPrice, amount) = calculatePaymentAmount(transportFee: transportFee)
        let bookingPayload = buildBookingPayload(
            transportDistanceKm: transportDistanceKm,
            transportFee: transportFee,
            customerAddressLat: customerAddressLat,
            customerAddressLng: customerAddressLng,
            amount: amount
        )

        guard let (bookingId, clientSecret) = await createBookingAndLogAnalytics(
            payload: bookingPayload,
            totalPrice: totalPrice
        ) else {
            return
        }

        let finalClientSecret: String?
        if let clientSecret = clientSecret {
            finalClientSecret = clientSecret
        } else {
            finalClientSecret = await createPaymentIntentIfNeeded(
                bookingId: bookingId,
                amount: amount
            )
        }

        guard let finalClientSecret = finalClientSecret else {
            return
        }

        await processPaymentWithClientSecret(
            clientSecret: finalClientSecret,
            bookingId: bookingId,
            amount: amount,
            totalPrice: totalPrice
        )
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func geocodeAddressAndCalculateDistance() async -> (distance: Double?, lat: Double?, lng: Double?) {
        var transportDistanceKm: Double? = calculatedTransportDistanceKm
        var customerAddressLat: Double?
        var customerAddressLng: Double?
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location {
                customerAddressLat = location.coordinate.latitude
                customerAddressLng = location.coordinate.longitude
                
                if transportDistanceKm == nil, detailer.lat != 0, detailer.lng != 0 {
                    let providerCoord = CLLocationCoordinate2D(latitude: detailer.lat, longitude: detailer.lng)
                    let customerCoord = CLLocationCoordinate2D(latitude: customerAddressLat!, longitude: customerAddressLng!)
                    let distanceService = DistanceServiceImplementation()
                    transportDistanceKm = distanceService.calculateDistance(from: providerCoord, to: customerCoord)
                }
            }
        } catch {
            print("⚠️ [Booking] Geocoding error:", error.localizedDescription)
        }
        
        return (transportDistanceKm, customerAddressLat, customerAddressLng)
    }
    
    private func calculatePaymentAmount(transportFee: Double) -> (totalPrice: Double, amount: Double) {
        let servicePrice = service.price
        let totalPrice = servicePrice + transportFee
        let amount = selectedPayment == .cash ? totalPrice * 0.20 : totalPrice
        return (totalPrice, amount)
    }
    
    private func buildBookingPayload(
        transportDistanceKm: Double?,
        transportFee: Double,
        customerAddressLat: Double?,
        customerAddressLng: Double?,
        amount: Double
    ) -> [String: Any] {
        var payload: [String: Any] = [
            "provider_id": detailer.id,
            "service_id": service.id,
            "date": date.toISODateString(),
            "start_time": time,
            "end_time": time,
            "address": address,
            "payment_method": selectedPayment == .cash ? "cash" : "card"
        ]
        
        if let distance = transportDistanceKm, distance > 0 {
            payload["transport_distance_km"] = distance
            payload["transport_fee"] = transportFee
        }
        
        if let lat = customerAddressLat, let lng = customerAddressLng {
            payload["customer_address_lat"] = lat
            payload["customer_address_lng"] = lng
        }
        
        if selectedPayment == .cash {
            payload["deposit_amount"] = amount
        }
        
        if !notes.trimmingCharacters(in: .whitespaces).isEmpty {
            payload["notes"] = notes.trimmingCharacters(in: .whitespaces)
        }
        
        return payload
    }
    
    @MainActor
    private func createBookingAndLogAnalytics(
        payload: [String: Any],
        totalPrice: Double
    ) async -> (bookingId: String, clientSecret: String?)? {
        let bookingRes = await engine.bookingService.createBooking(payload)
        
        guard case let .success(createResponse) = bookingRes else {
            if case let .failure(err) = bookingRes {
                FirebaseManager.shared.recordError(err, userInfo: ["action": "create_booking"])
                showAlert(err.localizedDescription)
            } else {
                showAlert(R.string.localizable.errorBookingTitle())
            }
            return nil
        }
        
        let bookingId = createResponse.booking.id
        
        FirebaseManager.shared.logEvent(
            FirebaseManager.Event.bookingCreated,
            parameters: [
                "booking_id": bookingId,
                "provider_id": detailer.id,
                "service_id": service.id,
                "price": totalPrice,
                "payment_method": selectedPayment == .cash ? "cash" : "card"
            ]
        )
        
        return (bookingId, createResponse.clientSecret)
    }
    
    @MainActor
    private func createPaymentIntentIfNeeded(bookingId: String, amount: Double) async -> String? {
        let intentResponse = await engine.paymentService.createPaymentIntent(
            bookingId: bookingId,
            amount: amount,
            currency: "eur"
        )
        
        guard case let .success(intent) = intentResponse else {
            if case let .failure(err) = intentResponse {
                showAlert("Erreur lors de la création du paiement: \(err.localizedDescription)")
            } else {
                showAlert(R.string.localizable.errorPaymentFailedMessage())
            }
            return nil
        }
        
        return intent.clientSecret
    }
    
    @MainActor
    private func processPaymentWithClientSecret(clientSecret: String, bookingId: String, amount: Double, totalPrice: Double) async {
        let paymentResult = await StripeManager.shared.confirmPayment(clientSecret)

        switch paymentResult {
        case .success:
            // Notification de paiement réussi
            NotificationsManager.shared.notifyPaymentSuccess(
                transactionId: bookingId,
                amount: amount
            )
            
            // Créer les données de confirmation
            self.confirmationData = BookingConfirmationData(
                bookingId: bookingId,
                providerName: detailer.displayName,
                serviceName: service.name,
                price: totalPrice,
                currency: "eur",
                date: date.toISODateString(),
                startTime: time,
                endTime: time,
                address: address,
                paymentMethod: selectedPayment == .cash ? "cash" : "card",
                isMultiService: false,
                servicesCount: 1
            )
            
            // 👉 navigation uniquement après success payment
            self.goToConfirmation = true

        case .failure(let message):
            // Notification de paiement échoué
            NotificationsManager.shared.notifyPaymentFailed(
                transactionId: bookingId
            )
            showAlert(message)

        case .canceled:
            // Notification de paiement annulé
            NotificationsManager.shared.notifyPaymentFailed(
                transactionId: bookingId
            )
            showAlert(R.string.localizable.shopPaymentCanceled())
        }
    }
}
