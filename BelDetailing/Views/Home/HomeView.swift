import SwiftUI
import RswiftResources
import CoreLocation

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var selectedFilter: DetailingFilter = .all

    @State private var selectedDetailer: Detailer?   // 👈 AJOUT

    init(engine: Engine) {
        _vm = StateObject(wrappedValue: HomeViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

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
                        onProfileTap: {}
                    )

                    // === FILTERS ===
                    HomeFiltersView(
                        filters: DetailingFilter.allCases,
                        selected: $selectedFilter
                    )
                    .padding(.top, -14)

                    // === À proximité ===
                    HomeNearbySection(
                        title: R.string.localizable.homeNearbyTitle(),
                        providers: vm.recommended,
                        onSelect: { provider in              // 👈 AJOUT
                            selectedDetailer = provider
                        }
                    )
                    .padding(.top, -6)

                    // === TOUS LES PRESTATAIRES ===
                    HomeAllProvidersSection(
                        title: R.string.localizable.homeAllProvidersTitle(),
                        providers: vm.filtered(by: selectedFilter),
                        onSelect: { provider in             // 👈 AJOUT
                            selectedDetailer = provider
                        }
                    )
                }
                .padding(.bottom, 20)
            }
            .navigationDestination(item: $selectedDetailer) { detailer in
                DetailerDetailView(id: detailer.id, engine: vm.engine)  // 👈 OUVERTURE DETAIL
            }
            .ignoresSafeArea(edges: .top)
            .task {
                await vm.load()
                locationManager.requestPermission()
            }
        }
    }
}

