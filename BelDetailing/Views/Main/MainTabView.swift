// MainTabView.swift
import SwiftUI
import RswiftResources

struct MainTabView: View {
  enum Tab: CaseIterable { case home, search, bookings, offers, profile }

  let engine: Engine
  @State private var selection: Tab = .home

  init(engine: Engine) { self.engine = engine }

  var body: some View {
    ZStack(alignment: .bottom) {
      // Contenu
      TabView(selection: $selection) {
        HomeView(engine: engine)
          .tag(Tab.home)
          .tabItem { EmptyView() } // on cache la barre système

        SearchView(engine: engine)
          .tag(Tab.search)
          .tabItem { EmptyView() }

        BookingsView(engine: engine)
          .tag(Tab.bookings)
          .tabItem { EmptyView() }

        OffersView(engine: engine)
          .tag(Tab.offers)
          .tabItem { EmptyView() }

        ProfileView(engine: engine)
          .tag(Tab.profile)
          .tabItem { EmptyView() }
      }
      .toolbar(.hidden, for: .tabBar) // ⬅️ cache la TabBar iOS
      .ignoresSafeArea(.keyboard)     // évite les sauts avec le clavier

      // Barre custom
      CustomTabBar(selection: $selection)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .ignoresSafeArea(edges: .bottom)
    }
  }
}
