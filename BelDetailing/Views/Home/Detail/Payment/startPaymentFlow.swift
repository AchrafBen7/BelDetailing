import UIKit
import StripePaymentSheet

extension BookingStep3View {

    @MainActor
    func startPaymentFlow() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }

        // ---------------------------------------------------------
        // 1️⃣ CRÉER LE PAYMENT INTENT (pré-autorisation)
        // ---------------------------------------------------------

        let amount = service.price

        let response = await engine.paymentService.createPaymentIntent(
            bookingId: "",      // sera retiré du backend plus tard
            amount: amount,
            currency: "eur"
        )

        guard case let .success(intent) = response else {
            showAlert("Payment error")
            return
        }

        let clientSecret = intent.clientSecret

        // ---------------------------------------------------------
        // 2️⃣ OUVRIR STRIPE PAYMENTSHEET
        // ---------------------------------------------------------

        let paymentResult = await StripeManager.shared.confirmPayment(clientSecret)

        switch paymentResult {
        case .success:
            break

        case .failure(let message):
            showAlert(message)
            return

        case .canceled:
            showAlert("Payment canceled")
            return
        }

        // Laisser Stripe se fermer un peu AVANT de créer la booking
        try? await Task.sleep(nanoseconds: 300_000_000)   // 0.3 sec


        // ---------------------------------------------------------
        // 3️⃣ CRÉER LA BOOKING APRÈS PRÉ-AUTORISATION
        // ---------------------------------------------------------

        let bookingPayload: [String: Any] = [
            "provider_id": detailer.id,
            "service_id": service.id,
            "date": date.toISODateString(),
            "start_time": time,
            "end_time": time,
            "address": address
        ]

        let bookingRes = await engine.bookingService.createBooking(bookingPayload)

        switch bookingRes {
        case .success:
            // 👉 navigation uniquement après success booking
            self.goToConfirmation = true

        case .failure(let err):
            showAlert(err.localizedDescription)
        }
    }
}
