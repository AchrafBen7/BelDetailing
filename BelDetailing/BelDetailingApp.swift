import SwiftUI

@main
struct BelDetailingApp: App {
    let engine = Engine(mock: true)

    init() {
        #if DEBUG
        // Als je echt wil dat alles reset bij elke run:
        // UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        // UserDefaults.standard.synchronize()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(engine: engine)
        }
    }
}
