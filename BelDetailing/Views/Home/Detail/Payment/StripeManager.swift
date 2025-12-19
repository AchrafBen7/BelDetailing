import Foundation
import StripePaymentSheet
import UIKit

final class StripeManager {
    static let shared = StripeManager()
    private init() {}

    func confirmPayment(_ clientSecret: String) async -> PaymentResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                guard let rootVC = UIApplication.topViewController() else {
                    continuation.resume(returning: .failure("Cannot present payment UI"))
                    return
                }

                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "BelDetailing"
                configuration.allowsDelayedPaymentMethods = false

                 let paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: clientSecret,
                    configuration: configuration
                )

                paymentSheet.present(from: rootVC) { result in
                    // On résume aussi sur le main par sécurité
                    DispatchQueue.main.async {
                        switch result {
                        case .completed:
                            continuation.resume(returning: .success)

                        case .failed(let error):
                            continuation.resume(returning: .failure(error.localizedDescription))

                        case .canceled:
                            continuation.resume(returning: .canceled)
                        }
                    }
                }
            }
        }
    }
}
