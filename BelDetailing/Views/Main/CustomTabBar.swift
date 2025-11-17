import SwiftUI
import RswiftResources

private struct TabItem: Identifiable {
    let id = UUID()
    let tab: MainTabView.Tab
    let systemName: String
    let a11yLabel: String
}

struct CustomTabBar: View {
    @Binding var selection: MainTabView.Tab
    var onDashboardReselect: () -> Void = {}   // 👈 nouveau param par défaut

    private let items: [TabItem] = [
        .init(tab: .home,     systemName: "house.fill",              a11yLabel: R.string.localizable.tabHome()),
        .init(tab: .search,   systemName: "magnifyingglass",         a11yLabel: R.string.localizable.tabSearch()),
        .init(tab: .bookings, systemName: "calendar.badge.clock",    a11yLabel: R.string.localizable.tabBookings()),
        .init(tab: .dashboard,systemName: "chart.bar.fill",          a11yLabel: R.string.localizable.tabDashboard()),
        .init(tab: .profile,  systemName: "person.crop.circle.fill", a11yLabel: R.string.localizable.tabProfile())
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(.white.opacity(0.12), lineWidth: 0.7)
                )
                .shadow(color: .black.opacity(0.45), radius: 10, y: -4)

            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            if selection == item.tab, item.tab == .dashboard {
                                // 👇 on est déjà sur dashboard et on reclique dessus
                                onDashboardReselect()
                            } else {
                                selection = item.tab
                            }
                        }
                    } label: {
                        Image(systemName: item.systemName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                selection == item.tab
                                    ? AnyView(Capsule().fill(Color.white.opacity(0.14)))
                                    : AnyView(Color.clear)
                            )
                            .clipShape(Capsule())
                            .accessibilityLabel(Text(item.a11yLabel))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(height: 76)
    }
}
