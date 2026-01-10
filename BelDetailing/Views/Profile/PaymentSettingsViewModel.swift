import SwiftUI
import Combine
import StripePaymentSheet

@MainActor
final class PaymentSettingsViewModel: ObservableObject {
    @Published var paymentMethods: [AppPaymentMethod] = []
    @Published var transactions: [PaymentTransaction] = []
    @Published var bookings: [Booking] = [] // Pour mapper transactions -> bookings
    @Published var isLoading = false
    @Published var errorText: String?

    @Published var paymentSheet: PaymentSheet?
    @Published var isPresentingPaymentSheet = false
    @Published var selectedTransaction: PaymentTransaction?

    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }
    
    func bookingForTransaction(_ transactionId: String) -> Booking? {
        return bookings.first { booking in
            booking.paymentIntentId == transactionId
        }
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
        
        // 3) Charger les bookings pour mapper avec les transactions
        await loadBookings()

        print("🔵 [PaymentsVM] load() END")
    }
    
    private func loadBookings() async {
        switch await engine.bookingService.getBookings(scope: nil, status: nil) {
        case .success(let bookings):
            self.bookings = bookings
        case .failure:
            break
        }
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

            let sheet = PaymentSheet(
                setupIntentClientSecret: setup.setupIntentClientSecret,
                configuration: config
            )
            self.paymentSheet = sheet

            self.isLoading = false
            await Task.yield()
            self.isPresentingPaymentSheet = true

        case .failure(let error):
            print("❌ [PaymentsVM] setup-intent failed:", error.localizedDescription)
            self.errorText = error.localizedDescription
            self.isLoading = false
        }

        print("🔵 [PaymentsVM] addPaymentMethod() END")
    }

    func delete(method: AppPaymentMethod) async {
        guard !method.isDefault else {
            errorText = "Impossible de supprimer la carte par défaut"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let res = await engine.paymentService.deletePaymentMethod(id: method.id)

        switch res {
        case .success:
            await load()
        case .failure(let err):
            errorText = err.localizedDescription
        }
    }
}
