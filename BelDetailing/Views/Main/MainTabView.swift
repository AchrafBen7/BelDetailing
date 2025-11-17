import SwiftUI
import RswiftResources

struct MainTabView: View {
    enum Tab: CaseIterable { case home, search, bookings, dashboard, profile }

    let engine: Engine
    @State private var selection: Tab = .home
    @State private var dashboardResetID = UUID()   // 👈 pour reset le Dashboard

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selection) {

                HomeView(engine: engine)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .tag(Tab.home)
                    .tabItem { EmptyView() }

                SearchView(engine: engine)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .tag(Tab.search)
                    .tabItem { EmptyView() }

                BookingsView(engine: engine)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .tag(Tab.bookings)
                    .tabItem { EmptyView() }

                // 🔥 Dashboard = onglet dédié, avec id dynamique
                DashboardProviderView(engine: engine)
                    .id(dashboardResetID)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .tag(Tab.dashboard)
                    .tabItem { EmptyView() }

                ProfileView(engine: engine)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .tag(Tab.profile)
                    .tabItem { EmptyView() }
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.keyboard)

            CustomTabBar(
                selection: $selection,
                onDashboardReselect: {
                    // 👇 Si on rappuie sur le tab Dashboard → reset
                    dashboardResetID = UUID()
                    selection = .dashboard
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, -4)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
