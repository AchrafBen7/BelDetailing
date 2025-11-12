//
//  MainTabFixedBar.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct MainTabFixedBar: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Spacer()
                tabButton(
                    icon: "house.fill",
                    title: R.string.localizable.tabHome(),
                    selected: true
                )
                Spacer()
                tabButton(
                    icon: "magnifyingglass.circle.fill",
                    title: R.string.localizable.tabSearch()
                )
                Spacer()
                tabButton(
                    icon: "calendar.badge.clock",
                    title: R.string.localizable.tabBookings()
                )
                Spacer()
                tabButton(
                    icon: "briefcase.fill",
                    title: R.string.localizable.tabOffers()
                )
                Spacer()
                tabButton(
                    icon: "person.crop.circle.fill",
                    title: R.string.localizable.tabProfile()
                )
                Spacer()
            }
            .padding(.top, 6)
            .padding(.bottom, 10)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func tabButton(icon: String, title: String, selected: Bool = false) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(selected ? Color.accentColor : .gray)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(selected ? Color.accentColor : .gray)
        }
    }
}
