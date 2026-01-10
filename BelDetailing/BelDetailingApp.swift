import SwiftUI
import GoogleSignIn
import StripePaymentSheet
import UserNotifications
import FirebaseCore
#if canImport(OneSignal)
import OneSignal
#endif

@main
struct BelDetailingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var loadingManager = LoadingOverlayManager()
    @StateObject private var downloadProgress = DownloadProgressManager()

    let engine: Engine
    
    init() {
        // ✅ OneSignal SDK est maintenant initialisé dans AppDelegate.didFinishLaunchingWithOptions
        // avec launchOptions (selon documentation officielle OneSignal)
        
        // Configure notifications (garder pour compatibilité et routing)
        UNUserNotificationCenter.current().delegate = NotificationsManager.shared
        // Stripe
        if let stripeKey = Bundle.main.object(forInfoDictionaryKey: "StripePublishableKey") as? String {
            StripeAPI.defaultPublishableKey = stripeKey
        } else {
            assertionFailure("❌ StripePublishableKey manquante dans Info.plist")
        }

        // Token
        if let token = StorageManager.shared.getAccessToken(), !token.isEmpty {
            NetworkClient.defaultHeaders["Authorization"] = "Bearer \(token)"
        }

        // Google
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            assertionFailure("❌ CLIENT_ID manquant dans Info.plist")
        }

        // NetworkClient configuré (progress manager branché dans body)
        let client = NetworkClient(server: Server.prod)
        self.engine = Engine(networkClient: client)
        
        // Configurer NotificationsManager avec le NotificationService
        NotificationsManager.shared.configure(notificationService: engine.notificationService)
        
        // Configurer Firebase (Crashlytics + Analytics)
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView(engine: engine)
                .environmentObject(loadingManager)
                .environmentObject(downloadProgress)
                .environmentObject(NotificationRouter.shared)
                .onAppear {
                    // Brancher les managers dans le client réseau
                    engine.networkClient.loadingManager = loadingManager
                    engine.networkClient.downloadProgressManager = downloadProgress
                }
        }
    }
}

