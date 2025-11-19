//
//  DateFormatter.swift
//  BelDetailing
//
//  Created by Achraf Benali on 13/11/2025.
//

import Foundation

enum DateFormatters {
    private static let tz = TimeZone(identifier: "Europe/Brussels")!
    /// Combine "yyyy-MM-dd" + "HH:mm" en Date (Europe/Brussels)
    static func isoDateTime(date: String, time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = tz
        dateFormatter.locale = Locale(identifier: "fr_BE") // parsing
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: "\(date) \(time)")
    }
    /// Parse "yyyy-MM-dd" → Date
    static func isoDate(_ date: String) -> Date? {
        let df = DateFormatter()
        df.timeZone = tz
        df.locale = Locale(identifier: "fr_BE")
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: date)
    }

    /// Affichage humain : ex. "Mar 3, 2025 at 5:30 PM" (selon la locale du device)
    static func humanDate(from date: String, time: String) -> String {
        guard let isoDate = isoDateTime(date: date, time: time) else {
            return "\(date) \(time)"
        }
        let out = DateFormatter()
        out.timeZone = tz
        out.locale = Locale.current
        out.dateStyle = .medium
        out.timeStyle = .short
        return out.string(from: isoDate)
    }
}
