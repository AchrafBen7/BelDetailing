import SwiftUI
import GoogleSignIn

@main
struct BelDetailingApp: App {
    let engine = Engine()

    init() {
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
