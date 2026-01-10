//
//  NotificationsViewModel.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import Combine

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let result = await engine.notificationService.getNotifications()
        switch result {
        case .success(let items):
            // Trier par date décroissante (plus récentes en premier)
            notifications = items.sorted { first, second in
                guard let firstDate = DateFormatters.iso8601(first.createdAt),
                      let secondDate = DateFormatters.iso8601(second.createdAt) else {
                    return false
                }
                return firstDate > secondDate
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            notifications = []
        }
    }
    
    func markAsRead(_ notification: NotificationItem) async {
        guard !notification.isRead else { return }
        
        let result = await engine.notificationService.markAsRead(id: notification.id)
        if case .success = result {
            // Mettre à jour localement
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                var updatedNotification = notification
                // Note: NotificationItem est une struct avec let, donc on doit recréer la liste
                // On utilise une approche différente: recharger les notifications
                await load()
            }
        }
    }
    
    func markAllAsRead() async {
        let unreadNotifications = notifications.filter { !$0.isRead }
        
        // Marquer toutes comme lues une par une
        for notification in unreadNotifications {
            await markAsRead(notification)
        }
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var hasUnread: Bool {
        unreadCount > 0
    }
}

