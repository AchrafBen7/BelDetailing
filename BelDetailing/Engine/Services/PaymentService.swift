import Foundation
@_spi(STP) import StripeCore

protocol PaymentService {
    func createPaymentIntent(
        bookingId: String,
        amount: Double,
        currency: String
    ) async -> APIResponse<PaymentIntent>

    func capturePayment(paymentIntentId: String) async -> APIResponse<Bool>
    func refundPayment(paymentIntentId: String) async -> APIResponse<Bool>

    func createSetupIntent() async -> APIResponse<SetupIntentResponse>
    func fetchPaymentMethods() async -> APIResponse<[PaymentMethod]>
    func fetchTransactions() async -> APIResponse<[PaymentTransaction]>
    func deletePaymentMethod(id: String) async -> APIResponse<Bool>
}

final class PaymentServiceNetwork: PaymentService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func createPaymentIntent(
        bookingId: String,
        amount: Double,
        currency: String
    ) async -> APIResponse<PaymentIntent> {
        await networkClient.call(
            endPoint: .paymentIntent,
            dict: [
                "bookingId": bookingId,
                "amount": amount,
                "currency": currency
            ]
        )
    }

    func capturePayment(paymentIntentId: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .paymentCapture,
            dict: ["paymentIntentId": paymentIntentId]
        )
    }

    func refundPayment(paymentIntentId: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .paymentRefund,
            dict: ["paymentIntentId": paymentIntentId]
        )
    }

    func createSetupIntent() async -> APIResponse<SetupIntentResponse> {
        await networkClient.call(
            endPoint: .paymentSetupIntent
        )
    }

    func fetchPaymentMethods() async -> APIResponse<[PaymentMethod]> {
        await networkClient.call(
            endPoint: .paymentMethods,
            wrappedInData: true
        )
    }

    func fetchTransactions() async -> APIResponse<[PaymentTransaction]> {
        await networkClient.call(
            endPoint: .paymentTransactions,
            wrappedInData: true
        )
    }

    func deletePaymentMethod(id: String) async -> APIResponse<Bool> {
        await networkClient.call(
            endPoint: .paymentMethodDelete(id: id) // label id: requis par APIEndPoint
        )
    }
}
