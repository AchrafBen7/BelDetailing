//
//  LocationManager.swift
//  BelDetailing
//

import Foundation
import CoreLocation
import Combine
import RswiftResources

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var cityName: String? = nil
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var coordinate: CLLocationCoordinate2D?   // ✅ LA DONNÉE CLÉ

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        print("📍 LocationManager → requestPermission")
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Auth status:", manager.authorizationStatus.rawValue)

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()

        case .denied, .restricted:
            cityName = R.string.localizable.locationFallbackCity()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    // MARK: - Location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("⚠️ didUpdateLocations but locations empty")
            return
        }

        print("📍 GPS received:", location.coordinate.latitude, location.coordinate.longitude)

        coordinate = location.coordinate
        reverseGeocode(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
        cityName = R.string.localizable.locationFallbackCity()
    }

    // MARK: - Reverse geocoding
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let city = placemarks?.first?.locality
            Task { @MainActor in
                self?.cityName = city ?? R.string.localizable.locationFallbackCity()
            }
        }
    }
}
