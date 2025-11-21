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
    /// Convertit un Date → "yyyy-MM-dd"
    static func onlyDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.timeZone = tz
        df.locale = Locale(identifier: "fr_BE")
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
    
    /// Convertit un ISO8601 -> "15 janvier 2024"
    static func displayDate(_ isoString: String) -> String {
        let df = ISO8601DateFormatter()
        df.timeZone = tz

        guard let date = df.date(from: isoString) else {
            return isoString        // fallback si parsing échoue
        }

        let out = DateFormatter()
        out.locale = Locale(identifier: Locale.current.identifier)  // FR, NL ou EN automatique
        out.timeZone = tz
        out.dateStyle = .long      // "15 janvier 2024"
        out.timeStyle = .none

        return out.string(from: date)
    }


}
