//
//  LocationManager.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
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

  override init() {
    super.init()
    manager.delegate = self
  }

  func requestPermission() {
    manager.requestWhenInUseAuthorization()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus

    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      manager.requestLocation()
    case .denied, .restricted:
      cityName = R.string.localizable.locationFallbackCity() // ex. "Choix de commune"
    case .notDetermined:
      break
    @unknown default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("❌ Location error:", error.localizedDescription)
    cityName = R.string.localizable.locationFallbackCity()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    reverseGeocode(location)
  }

  private func reverseGeocode(_ location: CLLocation) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
      if let city = placemarks?.first?.locality {
        Task { @MainActor in
          self?.cityName = city
        }
      } else {
        Task { @MainActor in
          self?.cityName = R.string.localizable.locationFallbackCity()
        }
      }
    }
  }
}
