//  MainTabView.swift

import SwiftUI
import RswiftResources

struct MainTabView: View {

    enum Tab: CaseIterable { case home, search, bookings, dashboard, profile }

    let engine: Engine
    @State private var dashboardResetID = UUID()

    @EnvironmentObject var mainTabSelection: MainTabSelection
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var profileResetID = UUID()

    // 👇 AJOUTE ÇA
    init(engine: Engine) {
        self.engine = engine
        
        // on cache complètement la tabbar système,
        // on garde seulement ta CustomTabBar
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $mainTabSelection.currentTab) {
                HomeView(engine: engine)
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.home)
                    .tabItem { EmptyView() }

                NavigationStack {
                    SearchView(engine: engine)
                }
                .tag(Tab.search)
                .environmentObject(tabBarVisibility)
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
                    .id(profileResetID)     // 👈 IMPORTANT
                    .environmentObject(tabBarVisibility)
                    .tag(Tab.profile)
                    .tabItem { EmptyView() }
            }
            .ignoresSafeArea(.keyboard)

            if !tabBarVisibility.isHidden {
                CustomTabBar(
                    selection: $mainTabSelection.currentTab,
                    onDashboardReselect: {
                        dashboardResetID = UUID()
                        mainTabSelection.currentTab = .dashboard
                    },
                    onProfileReselect: {
                        profileResetID = UUID()          // 👈 reset navigation
                        mainTabSelection.currentTab = .profile
                    }
                )

                .padding(.horizontal, 16)
                .padding(.bottom,-20)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: tabBarVisibility.isHidden)
    }
}
