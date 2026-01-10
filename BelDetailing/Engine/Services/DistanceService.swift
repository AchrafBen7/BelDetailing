//
//  DistanceService.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import CoreLocation

// MARK: - Protocol
protocol DistanceService {
    func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double // Returns distance in kilometers
}

// MARK: - Implementation
final class DistanceServiceImplementation: DistanceService {
    
    /// Calculate distance between two coordinates using Haversine formula
    /// Returns distance in kilometers
    func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        // Distance in meters
        let distanceInMeters = fromLocation.distance(from: toLocation)
        
        // Convert to kilometers
        return distanceInMeters / 1000.0
    }
}

// MARK: - Helper Extension
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0 // Returns in km
    }
}

