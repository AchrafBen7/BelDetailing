import SwiftUI
import RswiftResources

private struct TabItem: Identifiable {
    let id = UUID()
    let tab: MainTabView.Tab
    let systemName: String
    let a11yLabel: String
    var badgeCount: Int = 0
}

struct CustomTabBar: View {
    @Binding var selection: MainTabView.Tab
    var userRole: UserRole?
    var onDashboardReselect: () -> Void = {}
    var onProfileReselect: (() -> Void)? = nil
    
    @StateObject private var badgeManager = NotificationBadgeManager.shared
    
    // Items conditionnels selon le rôle
    private var items: [TabItem] {
        var tabs: [TabItem] = [
            .init(tab: .home,     systemName: "house.fill",              a11yLabel: R.string.localizable.tabHome()),
            .init(tab: .search,   systemName: "magnifyingglass",         a11yLabel: R.string.localizable.tabSearch())
        ]
        
        // Bookings pour customers, Offers pour providers
        if userRole == .provider {
            tabs.append(.init(
                tab: .offers,
                systemName: "briefcase.fill",
                a11yLabel: R.string.localizable.tabOffers(),
                badgeCount: badgeManager.offerBadgeCount
            ))
        } else {
            tabs.append(.init(
                tab: .bookings,
                systemName: "calendar.badge.clock",
                a11yLabel: R.string.localizable.tabBookings(),
                badgeCount: badgeManager.bookingBadgeCount
            ))
        }
        
        tabs.append(contentsOf: [
            .init(
                tab: .dashboard,
                systemName: "chart.bar.fill",
                a11yLabel: R.string.localizable.tabDashboard(),
                badgeCount: badgeManager.dashboardBadgeCount
            ),
            .init(tab: .profile,  systemName: "person.crop.circle.fill", a11yLabel: R.string.localizable.tabProfile())
        ])
        
        return tabs
    }
    
    var body: some View {
        ZStack {
            // Fond façon dock iOS : très arrondi + un peu plus haut
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.black) // tu peux tester .opacity(0.9) pour un effet plus soft
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .stroke(Color.white.opacity(0.10), lineWidth: 0.7)
                )
                .shadow(color: .black.opacity(0.45), radius: 12, y: -4)
            
            HStack(spacing: 12) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            if selection == item.tab {
                                // TAB RESELECTED
                                if item.tab == .dashboard {
                                    onDashboardReselect()
                                }
                                else if item.tab == .profile {
                                    onProfileReselect?()
                                }
                            } else {
                                // CHANGE TAB NORMAL
                                selection = item.tab
                            }
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: item.systemName)
                                .font(.system(size: 20, weight: .semibold))  // icônes un peu plus petites
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)                // plus proche du dock
                                .background(
                                    selection == item.tab
                                    ? AnyView(Capsule().fill(Color.white.opacity(0.18)))
                                    : AnyView(Color.clear)
                                )
                                .clipShape(Capsule())
                                .accessibilityLabel(Text(item.a11yLabel))
                            
                            // Badge de notification
                            if item.badgeCount > 0 {
                                Text("\(item.badgeCount > 99 ? "99+" : "\(item.badgeCount)")")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, item.badgeCount > 9 ? 4 : 5)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 16)  // plus d’espace comme le dock
            .padding(.vertical, 10)
        }
        .frame(height: 80)             // un peu plus haut pour le look “dock”
    }
}
