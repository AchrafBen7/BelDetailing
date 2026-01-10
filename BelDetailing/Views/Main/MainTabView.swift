//  MainTabView.swift

import SwiftUI
import RswiftResources

struct MainTabView: View {

    enum Tab: CaseIterable { case home, search, bookings, offers, dashboard, profile }

    let engine: Engine
    @State private var dashboardResetID = UUID()

    @EnvironmentObject var mainTabSelection: MainTabSelection
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @EnvironmentObject var notificationRouter: NotificationRouter
    @State private var profileResetID = UUID()
    @StateObject private var session = AppSession.shared
    
    // Navigation depuis notifications
    @State private var selectedBookingId: String? = nil
    @State private var selectedOfferId: String? = nil
    @State private var selectedTransactionId: String? = nil
    
    // 👇 AJOUTE ÇA
    init(engine: Engine) {
        self.engine = engine
        
        // on cache complètement la tabbar système,
        // on garde seulement ta CustomTabBar
        UITabBar.appearance().isHidden = true
    }
    
    // Détermine le rôle de l'utilisateur
    private var userRole: UserRole? {
        session.user?.role ?? engine.userService.fullUser?.role
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

                // Bookings pour customers, Offers pour providers
                Group {
                    if userRole == .provider {
                        NavigationStack {
                            OffersView(engine: engine)
                        }
                        .tag(Tab.offers)
                    } else {
                        BookingsView(engine: engine)
                            .tag(Tab.bookings)
                    }
                }
                .environmentObject(tabBarVisibility)
                .tabItem { EmptyView() }

                // ✅ Route unique Dashboard, contenu selon rôle
                DashboardEntryView(engine: engine)
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
            .onAppear {
                // Si l'utilisateur est provider et que l'onglet actuel est bookings, rediriger vers offers
                if userRole == .provider, mainTabSelection.currentTab == .bookings {
                    mainTabSelection.currentTab = .offers
                }
                // Si l'utilisateur est customer et que l'onglet actuel est offers, rediriger vers bookings
                if userRole == .customer, mainTabSelection.currentTab == .offers {
                    mainTabSelection.currentTab = .bookings
                }
            }
            .onChange(of: userRole) { newRole in
                // Si le rôle change, ajuster l'onglet actuel
                if newRole == .provider, mainTabSelection.currentTab == .bookings {
                    mainTabSelection.currentTab = .offers
                } else if newRole == .customer, mainTabSelection.currentTab == .offers {
                    mainTabSelection.currentTab = .bookings
                }
            }

            if !tabBarVisibility.isHidden {
                CustomTabBar(
                    selection: $mainTabSelection.currentTab,
                    userRole: userRole,
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
        .task {
            // S'assurer que la session est à jour
            await session.refresh(engine: engine)
        }
        .onChange(of: notificationRouter.destination) { destination in
            handleNotificationDestination(destination)
        }
        .sheet(item: Binding(
            get: { selectedBookingId.map { BookingNavigationItem(id: $0) } },
            set: { selectedBookingId = $0?.id }
        )) { item in
            NavigationStack {
                BookingDetailViewFromId(bookingId: item.id, engine: engine)
            }
        }
        .sheet(item: Binding(
            get: { selectedOfferId.map { OfferNavigationItem(id: $0) } },
            set: { selectedOfferId = $0?.id }
        )) { item in
            NavigationStack {
                OfferDetailView(engine: engine, offerId: item.id)
            }
        }
        .sheet(item: Binding(
            get: { selectedTransactionId.map { TransactionNavigationItem(id: $0) } },
            set: { selectedTransactionId = $0?.id }
        )) { item in
            // Naviguer vers Profile > Payment Settings pour voir la transaction
            NavigationStack {
                ProfileView(engine: engine)
            }
        }
    }
    
    // MARK: - Notification Routing
    
    private func handleNotificationDestination(_ destination: NotificationDestination?) {
        guard let destination = destination else { return }
        
        switch destination {
        case .booking(let id):
            selectedBookingId = id
            // Naviguer vers l'onglet bookings
            mainTabSelection.currentTab = userRole == .provider ? .dashboard : .bookings
            
        case .offer(let id):
            selectedOfferId = id
            // Naviguer vers l'onglet offers
            mainTabSelection.currentTab = userRole == .provider ? .offers : .dashboard
            
        case .payment(let transactionId):
            selectedTransactionId = transactionId
            // Naviguer vers l'onglet profile
            mainTabSelection.currentTab = .profile
            
        case .profile:
            mainTabSelection.currentTab = .profile
            
        case .dashboard:
            mainTabSelection.currentTab = .dashboard
            
        case .none:
            break
        }
        
        // Réinitialiser la destination après traitement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            notificationRouter.reset()
        }
    }
    
}

// MARK: - Navigation Items

private struct BookingNavigationItem: Identifiable {
    let id: String
}

private struct OfferNavigationItem: Identifiable {
    let id: String
}

private struct TransactionNavigationItem: Identifiable {
    let id: String
}
