//
//  MainTabView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct MainTabView: View {
    enum Tab: CaseIterable {
        case home, search, bookings, offers, dashboard, profile

        var title: String {
            switch self {
            case .home:      return R.string.localizable.tabHome()
            case .search:    return R.string.localizable.tabSearch()
            case .bookings:  return R.string.localizable.tabBookings()
            case .offers:    return R.string.localizable.tabOffers()
            case .dashboard: return R.string.localizable.tabDashboard()
            case .profile:   return R.string.localizable.tabProfile()
            }
        }

        var systemIcon: String {
            switch self {
            case .home:      return "house.fill"
            case .search:    return "magnifyingglass.circle.fill"
            case .bookings:  return "calendar.badge.clock"
            case .offers:    return "briefcase.fill"
            case .dashboard: return "chart.bar.fill"
            case .profile:   return "person.crop.circle.fill"
            }
        }
    }
  let engine: Engine
  @State private var selection: Tab = .home
  @State private var bounceHome = false
  @State private var bounceSearch = false
  @State private var bounceOffers = false
  @State private var bounceBookings = false
  @State private var bounceProfile = false

  var body: some View {
    VStack(spacing: 0) {
      Group {
        switch selection {
        case .home:     HomeView(engine: engine)
        case .search:   SearchView(engine: engine)
        case .bookings: BookingsView(engine: engine)
        case .offers:   OffersView(engine: engine)
        case .dashboard: DashboardView(engine: engine)
        case .profile:  ProfileView(engine: engine)
        }
      }
      tabbar
    }
  }

    private var tabbar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [Color(R.color.mainBackground.name),
                                    Color.black.opacity(0.05)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 6)
                .opacity(0.8)

            HStack {
                tabButton(.home, bounce: $bounceHome)
                tabButton(.search, bounce: $bounceSearch)
                tabButton(.offers, bounce: $bounceOffers)
                tabButton(.bookings, bounce: $bounceBookings)

                // ✅ Dashboard visible uniquement pour prestataires
                if engine.userService.currentUser?.role == .provider {
                    tabButton(.dashboard, bounce: $bounceProfile)
                }

                tabButton(.profile, bounce: $bounceProfile)
            }
            .background(Color(R.color.mainBackground.name))
        }
    }



  @ViewBuilder
  private func tabButton(_ tab: Tab, bounce: Binding<Bool>) -> some View {
    Button {
      withAnimation(.default) {
        selection = tab
        bounce.wrappedValue.toggle()
      }
    } label: {
      VStack(spacing: 2) {
        Image(systemName: tab.systemIcon)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(selection == tab ? Color.accentColor : .gray)
        Text(tab.title)
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(selection == tab ? Color.accentColor : .gray)
      }
      .frame(height: 48)
    }
    .buttonStyle(.plain)
    .symbolEffect(.bounce.byLayer.down, value: bounce.wrappedValue)
    .sensoryFeedback(.selection, trigger: bounce.wrappedValue)
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  MainTabView(engine: Engine(mock: true))
}
