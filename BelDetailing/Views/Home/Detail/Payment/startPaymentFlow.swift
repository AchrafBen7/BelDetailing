import UIKit
import StripePaymentSheet

extension BookingStep3View {

    @MainActor
    func startPaymentFlow() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }

        // ---------------------------------------------------------
        // 1️⃣ CRÉER LE PAYMENT INTENT (pré-autorisation)
        // ⚠️ IMPORTANT :
        // Ton backend multiplie déjà amount * 100 (centimes).
        // Donc on envoie simplement le prix en EUR.
        // ---------------------------------------------------------

        let amount = service.price

        let response = await engine.paymentService.createPaymentIntent(
            bookingId: "",          // TODO: à supprimer plus tard du backend
            amount: amount,
            currency: "eur"
        )

        guard case let .success(intent) = response else {
            showAlert("Payment error")
            return
        }

        let clientSecret = intent.clientSecret

        // ---------------------------------------------------------
        // 2️⃣ OUVRIR STRIPE PAYMENTSHEET POUR PRÉ-AUTORISER
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

        // Laisser Stripe se fermer proprement
        await MainActor.run {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.goToConfirmation = true
            }
        }

        // ---------------------------------------------------------
        // 3️⃣ CRÉER LA BOOKING APRÈS PRÉ-AUTORISATION
        // ---------------------------------------------------------

        let bookingPayload: [String: Any] = [
            "provider_id": detailer.id,
            "service_id": service.id,
            "date": date.toISODateString(),
            "start_time": time,
            "end_time": time,
            "address": address,
            "payment_intent_id": intent.id
        ]

        let bookingRes = await engine.bookingService.createBooking(bookingPayload)

        switch bookingRes {
        case .success:
            self.goToConfirmation = true
        case .failure(let err):
            showAlert(err.localizedDescription)
        }
    }
}
