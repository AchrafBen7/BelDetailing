//
//  AppDelegate.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import UIKit
import UserNotifications
#if canImport(OneSignal)
import OneSignal
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // ✅ INITIALISER ONESIGNAL SDK (selon documentation officielle OneSignal)
        // ⚠️ IMPORTANT : L'initialisation doit être dans AppDelegate.didFinishLaunchingWithOptions
        // avec launchOptions pour gérer correctement les notifications au démarrage
        #if canImport(OneSignal)
        if let oneSignalAppId = Bundle.main.object(forInfoDictionaryKey: "OneSignalAppID") as? String {
            // Enable verbose logging for debugging (retirer en production)
            OneSignal.Debug.setLogLevel(.LL_VERBOSE)
            
            // Initialize with your OneSignal App ID (avec launchOptions)
            OneSignal.initialize(oneSignalAppId, withLaunchOptions: launchOptions)
            
            // Use this method to prompt for push notifications.
            // ⚠️ RECOMMANDATION : Retirer cette méthode après tests et utiliser In-App Messages à la place
            OneSignal.Notifications.requestPermission({ accepted in
                print("✅ [OneSignal] Permission granted: \(accepted)")
            }, fallbackToSettings: true)
            
            // Écouter les notifications OneSignal pour routing
            OneSignal.Notifications.addClickListener { notification in
                print("🔔 [OneSignal] Notification tapped: \(notification.notificationId ?? "unknown")")
                if let userInfo = notification.additionalData {
                    Task { @MainActor in
                        NotificationRouter.shared.handleNotification(userInfo: userInfo)
                    }
                }
            }
        } else {
            print("⚠️ [OneSignal] OneSignalAppID manquant dans Info.plist")
        }
        #else
        print("ℹ️ [OneSignal] SDK not integrated. Skipping OneSignal initialization.")
        #endif
        
        // Le delegate des notifications est déjà configuré dans NotificationsManager
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            NotificationsManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            NotificationsManager.shared.didFailToRegisterForRemoteNotifications(error: error)
        }
    }
}

