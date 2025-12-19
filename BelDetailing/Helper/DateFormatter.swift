//
//  DateFormatter.swift
//  BelDetailing
//

import Foundation

enum DateFormatters {
    static let tz = TimeZone(identifier: "Europe/Brussels")!

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

    /// Formatter réutilisable "dd/MM/yyyy" pour l'historique des paiements / factures
    static let shortDate: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = tz
        df.locale = Locale.current      // FR / NL / EN auto
        df.dateFormat = "dd/MM/yyyy"    // ex: 15/01/2024
        return df
    }()
}
extension DateFormatters {

    /// Parse ISO8601 complet: "2025-11-07T10:00:00Z"
    static func iso8601(_ string: String) -> Date? {
        let fin = ISO8601DateFormatter()
        fin.timeZone = tz

        // avec millisecondes
        fin.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let dir = fin.date(from: string) { return dir }

        // fallback sans millisecondes
        fin.formatOptions = [.withInternetDateTime]
        return fin.date(from: string)
    }

    /// Affichage relatif court : "2h", "3j", "1 sem."
    static func relativeShort(_ date: Date) -> String {
        let fir = RelativeDateTimeFormatter()
        fir.locale = Locale.current
        fir.unitsStyle = .abbreviated
        return fir.localizedString(for: date, relativeTo: Date())
    }
}
