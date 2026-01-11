//
//  NotificationsManager.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import UserNotifications
import UIKit
import Combine
import OneSignalFramework

@MainActor
final class NotificationsManager: NSObject, ObservableObject {
    static let shared = NotificationsManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private var notificationService: NotificationService?
    private var deviceToken: String?
    private let router = NotificationRouter.shared
    
    override init() {
        // Note: notificationService sera injecté depuis Engine
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    func configure(notificationService: NotificationService) {
        self.notificationService = notificationService
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                isAuthorized = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
                return true
            }
            
            return false
        } catch {
            print("❌ [NotificationsManager] Error requesting authorization: \(error)")
            return false
        }
    }
    
    // MARK: - Remote Notifications
    
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        // ✅ OneSignal SDK gère automatiquement le device token
        // On peut juste logger le Player ID si disponible (optionnel, pour debug)
        if let playerId = OneSignal.User.pushSubscription.id {
            print("✅ [NotificationsManager] OneSignal Player ID: \(playerId)")
            // Envoyer le Player ID au backend pour associer avec l'utilisateur
            Task {
                await sendPlayerIdToBackend(playerId: playerId)
            }
        } else {
            print("⚠️ [NotificationsManager] OneSignal Player ID not yet available")
        }
        
        // Garder le device token APNs pour compatibilité (logs uniquement)
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
        print("✅ [NotificationsManager] APNs Device token: \(token)")
    }
    
    // Envoyer un identifiant push au backend
    private func sendPlayerIdToBackend(playerId: String) async {
        guard let notificationService = notificationService else {
            print("⚠️ [NotificationsManager] NotificationService not configured, skipping Player ID send")
            return
        }
        
        do {
            try await notificationService.subscribeDeviceToken(playerId: playerId)
            print("✅ [NotificationsManager] Player ID sent to backend: \(playerId)")
        } catch {
            print("❌ [NotificationsManager] Failed to send Player ID to backend: \(error)")
        }
    }
    
    // ✅ NOUVEAU : Fonction helper pour appeler OneSignal.login(userId)
    func loginOneSignal(userId: String) {
        OneSignal.login(userId)
        print("✅ [NotificationsManager] OneSignal login called for userId: \(userId)")
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("❌ [NotificationsManager] Failed to register: \(error)")
    }
    
    // MARK: - Local Notifications (fallback)
    
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String = UUID().uuidString,
        delay: TimeInterval = 1.0,
        userInfo: [AnyHashable: Any]? = nil
    ) {
        guard isAuthorized else {
            print("⚠️ [NotificationsManager] Not authorized, skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let userInfo = userInfo {
            content.userInfo = userInfo
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ [NotificationsManager] Error scheduling notification: \(error)")
            } else {
                print("✅ [NotificationsManager] Local notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Booking Notifications
    
    func notifyBookingConfirmed(bookingId: String, providerName: String, date: String) {
        let title = "Rendez-vous confirmé"
        let body = "Votre rendez-vous avec \(providerName) le \(date) est confirmé."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "booking-confirmed-\(bookingId)",
            userInfo: [
                "type": "booking_confirmed",
                "booking_id": bookingId
            ]
        )
        // Mettre à jour le badge
        NotificationBadgeManager.shared.incrementBookingBadge()
        NotificationCenter.default.post(name: NSNotification.Name("BookingNotificationReceived"), object: nil)
    }
    
    func notifyBookingDeclined(bookingId: String, providerName: String) {
        let title = "Rendez-vous refusé"
        let body = "\(providerName) a décliné votre demande de rendez-vous."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "booking-declined-\(bookingId)",
            userInfo: [
                "type": "booking_declined",
                "booking_id": bookingId
            ]
        )
        // Mettre à jour le badge
        NotificationBadgeManager.shared.incrementBookingBadge()
        NotificationCenter.default.post(name: NSNotification.Name("BookingNotificationReceived"), object: nil)
    }
    
    func notifyBookingCancelled(bookingId: String) {
        let title = "Rendez-vous annulé"
        let body = "Votre rendez-vous a été annulé."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "booking-cancelled-\(bookingId)",
            userInfo: [
                "type": "booking_cancelled",
                "booking_id": bookingId
            ]
        )
    }
    
    func notifyServiceStarted(bookingId: String, serviceName: String) {
        let title = "Service démarré"
        let body = "Le service \(serviceName) a commencé."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "service-started-\(bookingId)",
            userInfo: [
                "type": "service_started",
                "booking_id": bookingId
            ]
        )
        // Mettre à jour le badge
        NotificationBadgeManager.shared.incrementBookingBadge()
        NotificationCenter.default.post(name: NSNotification.Name("BookingNotificationReceived"), object: nil)
    }
    
    func notifyServiceCompleted(bookingId: String, serviceName: String) {
        let title = "Service terminé"
        let body = "Le service \(serviceName) est terminé."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "service-completed-\(bookingId)",
            userInfo: [
                "type": "service_completed",
                "booking_id": bookingId
            ]
        )
    }
    
    func notifyProgressUpdate(bookingId: String, progress: Int, stepName: String) {
        let title = "Mise à jour du service"
        let body = "\(stepName) — Avancement: \(progress)%"
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "progress-update-\(bookingId)-\(UUID().uuidString)",
            userInfo: [
                "type": "progress_update",
                "booking_id": bookingId
            ]
        )
        // Mettre à jour le badge (mais pas à chaque update pour éviter spam)
        // On incrémente seulement pour les milestones (25%, 50%, 75%, 100%)
        if progress == 25 || progress == 50 || progress == 75 || progress == 100 {
            NotificationBadgeManager.shared.incrementBookingBadge()
            NotificationCenter.default.post(name: NSNotification.Name("BookingNotificationReceived"), object: nil)
        }
    }
    
    func notifyCounterProposalSent(bookingId: String) {
        let title = "Contre-proposition envoyée"
        let body = "Votre contre-proposition a été envoyée au client."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "counter-proposal-sent-\(bookingId)",
            userInfo: [
                "type": "counter_proposal_sent",
                "booking_id": bookingId
            ]
        )
    }
    
    func notifyCounterProposalAccepted(bookingId: String) {
        let title = "Contre-proposition acceptée"
        let body = "Le client a accepté votre contre-proposition."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "counter-proposal-accepted-\(bookingId)",
            userInfo: [
                "type": "counter_proposal_accepted",
                "booking_id": bookingId
            ]
        )
    }
    
    func notifyCounterProposalRefused(bookingId: String) {
        let title = "Contre-proposition refusée"
        let body = "Le client a refusé votre contre-proposition."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "counter-proposal-refused-\(bookingId)",
            userInfo: [
                "type": "counter_proposal_refused",
                "booking_id": bookingId
            ]
        )
    }
    
    // MARK: - Payment Notifications
    
    func notifyPaymentSuccess(transactionId: String, amount: Double) {
        let title = "Paiement réussi"
        let amountStr = String(format: "%.2f", amount)
        let body = "Paiement de \(amountStr) € confirmé."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "payment-success-\(transactionId)",
            userInfo: [
                "type": "payment_succeeded",
                "transaction_id": transactionId
            ]
        )
        // Pas de badge pour les paiements réussis (pas besoin de notification)
    }
    
    func notifyPaymentFailed(transactionId: String) {
        let title = "Paiement échoué"
        let body = "Votre paiement a échoué."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "payment-failed-\(transactionId)",
            userInfo: [
                "type": "payment_failed",
                "transaction_id": transactionId
            ]
        )
    }
    
    func notifyRefundProcessed(transactionId: String, amount: Double) {
        let title = "Remboursement effectué"
        let amountStr = String(format: "%.2f", amount)
        let body = "Remboursement de \(amountStr) € effectué."
        scheduleLocalNotification(
            title: title,
            body: body,
            identifier: "refund-processed-\(transactionId)",
            userInfo: [
                "type": "refund",
                "transaction_id": transactionId
            ]
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationsManager: UNUserNotificationCenterDelegate {
    // Appelé quand la notification arrive et que l'app est au premier plan
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Afficher la notification même si l'app est au premier plan
        completionHandler([.banner, .sound, .badge])
    }
    
    // Appelé quand l'utilisateur tape sur la notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("🔔 [NotificationsManager] Notification tapped: \(userInfo)")
        
        // Router vers la bonne vue selon le type de notification
        Task { @MainActor in
            router.handleNotification(userInfo: userInfo)
        }
        
        completionHandler()
    }
}

