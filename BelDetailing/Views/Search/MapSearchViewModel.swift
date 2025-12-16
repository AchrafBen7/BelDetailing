//
//  MapSearchViewModel.swift
//  BelDetailing
//

import Foundation
import MapKit
import Combine

@MainActor
final class MapSearchViewModel: ObservableObject {

    // MARK: - Dependencies
    let engine: Engine
    let locationManager: LocationManager
    var cancellables = Set<AnyCancellable>()

    // MARK: - Published (UI)
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    @Published var userCoordinate: CLLocationCoordinate2D?
    @Published var providers: [Detailer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var radiusKm: Double = 10
    @Published var selectedProvider: Detailer?

    // MARK: - Init
    init(engine: Engine, locationManager: LocationManager) {
        self.engine = engine
        self.locationManager = locationManager

        bindLocation()
    }

    // MARK: - Bind GPS
    private func bindLocation() {
        locationManager.$coordinate
            .compactMap { $0 }
            .removeDuplicates(by: { $0.latitude == $1.latitude && $0.longitude == $1.longitude })
            .sink { [weak self] coord in
                guard let self else { return }
                print("🧭 Map VM received coord:", coord.latitude, coord.longitude)

                self.userCoordinate = coord
                self.updateRegion(to: coord)
                self.fetchNearby()
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch providers
    func fetchNearby() {
        guard let coord = userCoordinate else {
            print("⚠️ fetchNearby called but userCoordinate nil")
            return
        }

        print("🔎 fetchNearby lat/lng/radius:", coord.latitude, coord.longitude, radiusKm)

        isLoading = true
        errorMessage = nil

        Task {
            let response = await engine.userService.providersNearby(
                lat: coord.latitude,
                lng: coord.longitude,
                radius: radiusKm
            )

            switch response {
            case .success(let items):
                print("📦 providers received:", items.count)
                self.providers = items

            case .failure(let err):
                print("❌ providers error:", err.localizedDescription ?? "nil")
                self.errorMessage = err.localizedDescription
                self.providers = []
            }

            self.isLoading = false
        }
    }

    // MARK: - Radius
    func onRadiusChanged(_ newValue: Double) {
        radiusKm = newValue
        fetchNearby()
    }

    // MARK: - Map region
    private func updateRegion(to coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    }
    func focus(on provider: Detailer) {
        region.center = CLLocationCoordinate2D(
            latitude: provider.lat,
            longitude: provider.lng
        )
        region.span = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    }

}
