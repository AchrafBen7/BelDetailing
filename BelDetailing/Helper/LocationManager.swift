//
//  LocationManager.swift
//  BelDetailing
//
//  Gestion centralisée de la localisation GPS
//  - Détection d'arrivée (No-Show Protection)
//  - Affichage de la ville (HomeView)
//  - Recherche de providers à proximité
//

import Foundation
import CoreLocation
import Combine
import RswiftResources

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Published Properties
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isLocationEnabled: Bool = false
    
    // Pour HomeView et MapSearchView
    @Published var cityName: String?
    @Published var coordinate: CLLocationCoordinate2D?
    
    private var locationUpdateTimer: Timer?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Mettre à jour toutes les 10 mètres
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// Demande l'autorisation de localisation
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Alias pour compatibilité avec HomeView
    func requestPermission() {
        requestAuthorization()
    }
    
    /// Démarre les mises à jour de localisation
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    /// Arrête les mises à jour de localisation
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    /// Demande une seule mise à jour de localisation (pour HomeView)
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        locationManager.requestLocation()
    }
    
    // MARK: - Distance Calculations
    
    /// Vérifie si le provider est proche de l'adresse du booking (dans un rayon de 50m)
    func isNearBookingAddress(bookingAddress: String, bookingLat: Double?, bookingLng: Double?) -> Bool {
        guard let currentLocation = currentLocation,
              let bookingLat = bookingLat,
              let bookingLng = bookingLng else {
            return false
        }
        
        let bookingLocation = CLLocation(latitude: bookingLat, longitude: bookingLng)
        let distance = currentLocation.distance(from: bookingLocation)
        
        // Rayon de 50 mètres
        return distance <= 50.0
    }
    
    /// Calcule la distance jusqu'à l'adresse du booking
    func distanceToBookingAddress(bookingLat: Double?, bookingLng: Double?) -> Double? {
        guard let currentLocation = currentLocation,
              let bookingLat = bookingLat,
              let bookingLng = bookingLng else {
            return nil
        }
        
        let bookingLocation = CLLocation(latitude: bookingLat, longitude: bookingLng)
        return currentLocation.distance(from: bookingLocation)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Demander la localisation pour HomeView
            manager.requestLocation()
            // Démarrer les mises à jour continues pour No-Show Protection
            if isLocationEnabled {
                manager.startUpdatingLocation()
            }
            
        case .denied, .restricted:
            cityName = R.string.localizable.locationFallbackCity()
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Mettre à jour les propriétés
        currentLocation = location
        coordinate = location.coordinate
        
        // Reverse geocoding pour obtenir le nom de la ville
        reverseGeocode(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
        cityName = R.string.localizable.locationFallbackCity()
    }
    
    // MARK: - Reverse Geocoding
    
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

