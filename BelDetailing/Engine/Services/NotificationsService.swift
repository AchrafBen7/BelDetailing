//
//  NotificationsService.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/11/2025.
//

import Foundation

struct NotificationItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let message: String
    let type: String   // ex: "booking", "offer", "system"
    let createdAt: String
    let isRead: Bool
}

protocol NotificationService {
    func getNotifications() async -> APIResponse<[NotificationItem]>
    func markAsRead(id: String) async -> APIResponse<Bool>
    func subscribeToTopic(_ topic: String) async -> APIResponse<Bool>
}

final class NotificationServiceNetwork: NotificationService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func getNotifications() async -> APIResponse<[NotificationItem]> {
        await networkClient.call(endPoint: .notificationsList)
    }

    func markAsRead(id: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .notificationRead(id: id))
    }

    func subscribeToTopic(_ topic: String) async -> APIResponse<Bool> {
        await networkClient.call(endPoint: .notificationSubscribe(topic: topic))
    }
}

final class NotificationServiceMock: MockService, NotificationService {
    func getNotifications() async -> APIResponse<[NotificationItem]> {
        await randomWait()
        return .success([
            NotificationItem(id: "not_001", title: "Réservation confirmée", message: "Votre lavage est confirmé pour demain 10h.", type: "booking", createdAt: "2025-11-07T09:00:00Z", isRead: false),
            NotificationItem(id: "not_002", title: "Nouvelle candidature", message: "Un prestataire a postulé à votre offre.", type: "offer", createdAt: "2025-11-06T12:30:00Z", isRead: true)
        ])
    }

    func markAsRead(id: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }

    func subscribeToTopic(_ topic: String) async -> APIResponse<Bool> {
        await randomWait()
        return .success(true)
    }
}
