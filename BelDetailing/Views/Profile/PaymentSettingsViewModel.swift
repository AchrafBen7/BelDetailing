import SwiftUI
import Combine
import StripePaymentSheet

@MainActor
final class PaymentSettingsViewModel: ObservableObject {
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var transactions: [PaymentTransaction] = []
    @Published var isLoading = false
    @Published var errorText: String?

    @Published var paymentSheet: PaymentSheet?
    @Published var isPresentingPaymentSheet = false

    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        print("🔵 [PaymentsVM] load() BEGIN")

        // 1) Cartes
        switch await engine.paymentService.fetchPaymentMethods() {
        case .success(let methods):
            print("✅ [PaymentsVM] fetchPaymentMethods success — count:", methods.count)
            self.paymentMethods = methods
        case .failure(let error):
            print("❌ [PaymentsVM] fetchPaymentMethods failed:", error.localizedDescription)
            self.errorText = error.localizedDescription
        }

        // 2) Transactions Stripe (backend)
        switch await engine.paymentService.fetchTransactions() {
        case .success(let tx):
            print("✅ [PaymentsVM] fetchTransactions success — count:", tx.count)
            self.transactions = tx
        case .failure(let error):
            print("❌ [PaymentsVM] fetchTransactions failed:", error.localizedDescription)
        }

        print("🔵 [PaymentsVM] load() END")
    }

    func addPaymentMethod() async {
        print("🔵 [PaymentsVM] addPaymentMethod() BEGIN")
        isLoading = true

        print("🔵 [PaymentsVM] requesting setup-intent…")
        let result = await engine.paymentService.createSetupIntent()
        switch result {
        case .success(let setup):
            print("✅ [PaymentsVM] setup-intent OK — customerId:", setup.customerId,
                  " ephKey:", setup.ephemeralKeySecret.prefix(10),
                  " si:", setup.setupIntentClientSecret.prefix(12))

            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "BelDetailing"
            config.customer = .init(
                id: setup.customerId,
                ephemeralKeySecret: setup.ephemeralKeySecret
            )
            config.allowsDelayedPaymentMethods = false

            // Création de la PaymentSheet (SetupIntent pour ajout de carte)
            print("🔧 [PaymentsVM] creating PaymentSheet (setup)…")
            let sheet = PaymentSheet(
                setupIntentClientSecret: setup.setupIntentClientSecret,
                configuration: config
            )
            self.paymentSheet = sheet
            print("🧾 [PaymentsVM] PaymentSheet created")

            // 1) Retirer l’overlay AVANT la présentation
            self.isLoading = false

            await Task.yield()
            
            // 2) Déclencher la présentation côté Vue (modifier conditionnel)
            self.isPresentingPaymentSheet = true
            print("📣 [PaymentsVM] isPresentingPaymentSheet = true (should present)")

        case .failure(let error):
            print("❌ [PaymentsVM] setup-intent failed:", error.localizedDescription)
            self.errorText = error.localizedDescription
            self.isLoading = false
        }

        print("🔵 [PaymentsVM] addPaymentMethod() END")
    }
}
