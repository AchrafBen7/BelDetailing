//
//  NotificationBadgeManager.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import Foundation
import Combine
import UserNotifications

/// Gère les badges de notifications pour les différents onglets
@MainActor
final class NotificationBadgeManager: ObservableObject {
    static let shared = NotificationBadgeManager()
    
    @Published var bookingBadgeCount: Int = 0
    @Published var offerBadgeCount: Int = 0
    @Published var dashboardBadgeCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Écouter les notifications pour mettre à jour les badges
        NotificationCenter.default.publisher(for: NSNotification.Name("BookingNotificationReceived"))
            .sink { [weak self] _ in
                self?.incrementBookingBadge()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("OfferNotificationReceived"))
            .sink { [weak self] _ in
                self?.incrementOfferBadge()
            }
            .store(in: &cancellables)
        
        // Mettre à jour le badge de l'app
        $bookingBadgeCount
            .combineLatest($offerBadgeCount, $dashboardBadgeCount)
            .sink { [weak self] booking, offer, dashboard in
                let total = booking + offer + dashboard
                self?.updateAppBadge(count: total)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Badge Management
    
    func incrementBookingBadge() {
        bookingBadgeCount += 1
    }
    
    func incrementOfferBadge() {
        offerBadgeCount += 1
    }
    
    func incrementDashboardBadge() {
        dashboardBadgeCount += 1
    }
    
    func resetBookingBadge() {
        bookingBadgeCount = 0
    }
    
    func resetOfferBadge() {
        offerBadgeCount = 0
    }
    
    func resetDashboardBadge() {
        dashboardBadgeCount = 0
    }
    
    func resetAllBadges() {
        bookingBadgeCount = 0
        offerBadgeCount = 0
        dashboardBadgeCount = 0
    }
    
    // MARK: - App Badge
    
    private func updateAppBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                print("❌ [NotificationBadgeManager] Failed to update app badge: \(error)")
            }
        }
    }
}

