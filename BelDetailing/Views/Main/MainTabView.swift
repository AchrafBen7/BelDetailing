//
//  MainTabView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct MainTabView: View {

    enum Tab: CaseIterable { case home, search, bookings, dashboard, profile }

    let engine: Engine

    @State private var dashboardResetID = UUID()

    // 👉 Maintenant la sélection vient d’un ObservableObject global
    @EnvironmentObject var mainTabSelection: MainTabSelection
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $mainTabSelection.currentTab) {

                HomeView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.home)
                    .tabItem { EmptyView() }

                SearchView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.search)
                    .tabItem { EmptyView() }

                BookingsView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.bookings)
                    .tabItem { EmptyView() }

                DashboardProviderView(engine: engine)
                    .id(dashboardResetID)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.dashboard)
                    .tabItem { EmptyView() }

                ProfileView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.profile)
                    .tabItem { EmptyView() }
            }
            .ignoresSafeArea(.keyboard)

            // === CUSTOM TAB BAR ===
            if !tabBarVisibility.isHidden {
                CustomTabBar(
                    selection: $mainTabSelection.currentTab,
                    onDashboardReselect: {
                        dashboardResetID = UUID()
                        mainTabSelection.currentTab = .dashboard
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, -4)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: tabBarVisibility.isHidden)
    }
}
