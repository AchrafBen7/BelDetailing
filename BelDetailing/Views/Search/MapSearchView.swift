import SwiftUI
import MapKit

struct MapSearchView: View {

    @StateObject private var viewModel: MapSearchViewModel
    @StateObject private var locationManager: LocationManager

    @State private var selectedProviderForMap: Detailer?
    @State private var selectedProviderToOpen: Detailer?

    // MARK: - Init
    init(engine: Engine) {
        let loc = LocationManager()
        _locationManager = StateObject(wrappedValue: loc)
        _viewModel = StateObject(
            wrappedValue: MapSearchViewModel(
                engine: engine,
                locationManager: loc
            )
        )
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {

            // ===========================
            // MARK: MAP (comme SearchView)
            // ===========================
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.providers) { provider in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: provider.lat,
                        longitude: provider.lng
                    )
                ) {
                    Button {
                        withAnimation(.easeInOut) {
                            selectedProviderForMap = provider
                            selectedProviderToOpen = provider
                            viewModel.focus(on: provider)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(
                                    .system(
                                        size: selectedProviderForMap?.id == provider.id ? 38 : 26
                                    )
                                )
                                .foregroundColor(.black)
                                .shadow(radius: 4)

                            if selectedProviderForMap?.id == provider.id {
                                Text(provider.displayName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(radius: 3)
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                   value: selectedProviderForMap)
                    }
                }
            }
            .ignoresSafeArea()

            // ===========================
            // MARK: TOP CONTROLS
            // ===========================
            controls
        }
        // ===========================
        // MARK: NAVIGATION
        // ===========================
        .navigationDestination(item: $selectedProviderToOpen) { provider in
            DetailerDetailView(id: provider.id, engine: viewModel.engine)
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }

    // MARK: - Controls
    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("Rayon: \(Int(viewModel.radiusKm)) km")
                    .font(.system(size: 14, weight: .medium))

                Slider(
                    value: Binding(
                        get: { viewModel.radiusKm },
                        set: { viewModel.onRadiusChanged($0) }
                    ),
                    in: 1...30,
                    step: 1
                )

                Button {
                    viewModel.fetchNearby()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black.opacity(0.22)))
            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        }
        .padding(.top, 10)
    }
}
