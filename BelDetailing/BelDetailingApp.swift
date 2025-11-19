import SwiftUI

@main
struct BelDetailingApp: App {
    let engine = Engine(mock: true)
    @StateObject var tabBarVisibility = TabBarVisibility()

    var body: some Scene {
        WindowGroup {
            RootView(engine: engine)
                .environmentObject(tabBarVisibility)
        }
    }
}
