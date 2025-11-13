import SwiftUI
import RswiftResources
import CoreLocation

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var selectedFilter: DetailingFilter = .all

    init(engine: Engine) {
        _vm = StateObject(wrappedValue: HomeViewModel(engine: engine))
    }

    private var filters: [DetailingFilter] { DetailingFilter.allCases }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) { // ⬅️ spacing général réduit (28 → 20)

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
                .padding(.top, -14) // ⬅️ rapproché de la hero
                .padding(.bottom, -4) // ⬅️ colle un peu plus le “Nearby”

                // === À proximité ===
                HomeNearbySection(
                    title: R.string.localizable.homeNearbyTitle(),
                    providers: vm.recommended
                )
                .padding(.top, -6) // ⬅️ fait remonter “Nearby” visuellement

                // === TOUS LES PRESTATAIRES ===
                HomeAllProvidersSection(
                    title: R.string.localizable.homeAllProvidersTitle(),
                    providers: vm.filtered(by: selectedFilter)
                )
            }
            .padding(.bottom, 20)
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
