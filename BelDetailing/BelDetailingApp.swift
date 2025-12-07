import SwiftUI
import GoogleSignIn
import StripePaymentSheet

@main
struct BelDetailingApp: App {
    let engine = Engine()

    init() {
        //
        // 1️⃣ Stripe Publishable Key depuis Info.plist
        //
        if let stripeKey = Bundle.main.object(forInfoDictionaryKey: "StripePublishableKey") as? String {
            StripeAPI.defaultPublishableKey = stripeKey
        } else {
            assertionFailure("❌ StripePublishableKey manquante dans Info.plist")
        }

        //
        // 2️⃣ Restaurer le token existant
        //
        if let token = StorageManager.shared.getAccessToken(), !token.isEmpty {
            NetworkClient.defaultHeaders["Authorization"] = "Bearer \(token)"
        }

        //
        // 3️⃣ Configuration Google Sign-In
        //
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            assertionFailure("❌ CLIENT_ID manquant dans Info.plist")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(engine: engine)
        }
    }
}
