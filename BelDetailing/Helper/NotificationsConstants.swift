//
//  NotificationsConstants.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import Foundation

enum NotificationsConstants: String {
  case didCreateTrip

  var notificationName: Notification.Name {
    Notification.Name(rawValue: self.rawValue)
  }

  var publisher: NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: notificationName)
  }

  func post(object: Any? = nil) {
    NotificationCenter.default.post(name: notificationName, object: object)
  }
}
