//
//  BelDetailingApp.swift
//  BelDetailing
//
//  Created by Achraf Benali on 04/11/2025.
//// BelDetailingApp.swift

/*import SwiftUI
@main
struct BelDetailingApp: App {
  let engine = Engine(mock: true)

  init() {
    #if DEBUG
    // ⚠️ Efface les UserDefaults à chaque lancement
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    print("🧹 UserDefaults reset – app considérée comme premier lancement")
    #endif
  }

  var body: some Scene {
    WindowGroup {
      RootView(engine: engine)
    }
  }
}*/

import SwiftUI

@main
struct BelDetailingApp: App {
  // un seul engine mock partagé
  private let engine = Engine(mock: true)

  var body: some Scene {
    WindowGroup {
      HomeView(engine: engine)   // ⬅️ démarre directement sur le Home
    }
  }
}
