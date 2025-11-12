//
//  HomeView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources
import CoreLocation

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @StateObject private var locationManager = LocationManager()

    // ✅ filtre typé (plus de String)
    @State private var selectedFilter: DetailingFilter = .all

    init(engine: Engine) {
        _vm = StateObject(wrappedValue: HomeViewModel(engine: engine))
    }

    // ✅ toutes les options depuis l'enum (localisable via .title)
    private var filters: [DetailingFilter] { DetailingFilter.allCases }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // === HERO SECTION ===
                    HomeHeroSection(
                        cityName: locationManager.cityName ?? R.string.localizable.defaultCityName(),
                        heroImageName: R.image.heroMain.name,
                        title: R.string.localizable.homeHeroTitle(),
                        subtitle: R.string.localizable.homeHeroSubtitle(),
                        onLocationTap: {
                            if locationManager.authorizationStatus == .notDetermined {
                                locationManager.requestPermission()
                            }
                        },
                        onProfileTap: { /* TODO: nav profile */ }
                    )

                    // === FILTERS ===
                    HomeFiltersView(
                        filters: filters,
                        selected: $selectedFilter
                    )
                    .padding(.top, -6)

                    // === À proximité / Nearby ===
                    HomeNearbySection(
                        title: R.string.localizable.homeNearbyTitle(),
                        providers: vm.recommended
                    )

                    // === TOUS LES PRESTATAIRES ===
                    HomeAllProvidersSection(
                        title: R.string.localizable.homeAllProvidersTitle(),
                        providers: vm.filtered(by: selectedFilter)
                    )
                    .padding(.bottom, 90)

                    .padding(.bottom, 90)
                }
            }

            Divider()
            MainTabFixedBar()
                .padding(.bottom, 8)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .ignoresSafeArea(edges: .top)
        .task {
            await vm.load()
            locationManager.requestPermission()
        }
    }
}

#Preview {
    HomeView(engine: Engine(mock: true))
}
