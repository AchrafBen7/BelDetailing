import SwiftUI
import RswiftResources
import CoreLocation

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @StateObject private var locationManager = LocationManager.shared
    @State private var selectedFilter: DetailingFilter = .all

    @State private var selectedDetailer: Detailer?   // 👈 AJOUT

    init(engine: Engine) {
        _vm = StateObject(wrappedValue: HomeViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
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
                        
                        // === SECTION BLANCHE ARRONDIE ===
                        VStack(alignment: .leading, spacing: 0) {
                            // === FILTERS ===
                            HomeFiltersView(
                                filters: DetailingFilter.allCases,
                                selected: $selectedFilter
                            )
                            .padding(.top, 20)
                            
                            // === À proximité ===
                            HomeNearbySection(
                                title: R.string.localizable.homeNearbyTitle(),
                                providers: vm.recommended,
                                onSelect: { provider in
                                    selectedDetailer = provider
                                }
                            )
                            .padding(.top, 12)
                            
                            // === TOUS LES PRESTATAIRES ===
                            HomeAllProvidersSection(
                                title: R.string.localizable.homeAllProvidersTitle(),
                                providers: vm.filtered(by: selectedFilter),
                                onSelect: { provider in
                                    selectedDetailer = provider
                                }
                            )
                            .padding(.top, 12)
                        }
                        .background(Color.white)
                        .cornerRadius(32, corners: [.topLeft, .topRight])
                        .padding(.top, -32) // Superposition avec le hero
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(item: $selectedDetailer) { detailer in
                DetailerDetailView(id: detailer.id, engine: vm.engine)
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.white)
            .task {
                await vm.load()
                locationManager.requestPermission()
            }
        }
    }
}

