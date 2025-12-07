protocol PaymentService {
    func createPaymentIntent(bookingId: String, amount: Double, currency: String) async -> APIResponse<PaymentIntent>
    func capturePayment(paymentIntentId: String) async -> APIResponse<Bool>
    func refundPayment(paymentIntentId: String) async -> APIResponse<Bool>
}

final class PaymentServiceNetwork: PaymentService {

    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func createPaymentIntent(bookingId: String, amount: Double, currency: String) async -> APIResponse<PaymentIntent> {

        let dict: [String: Any] = [
            "bookingId": bookingId,
            "amount": amount,
            "currency": currency
        ]

        return await networkClient.call(
            endPoint: .paymentIntent,
            dict: dict
        )
    }

    func capturePayment(paymentIntentId: String) async -> APIResponse<Bool> {

        let dict = ["paymentIntentId": paymentIntentId]

        return await networkClient.call(
            endPoint: .paymentCapture,
            dict: dict
        )
    }

    func refundPayment(paymentIntentId: String) async -> APIResponse<Bool> {

        let dict = ["paymentIntentId": paymentIntentId]

        return await networkClient.call(
            endPoint: .paymentRefund,
            dict: dict
        )
    }
}
