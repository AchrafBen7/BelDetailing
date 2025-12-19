extension Offer {

    var displayPrice: String {
        switch type {
        case .recurring:
            return "\(Int(priceMin))€/mois"
        case .oneTime, .longTerm:
            return "\(Int(priceMin))€"
        }
    }

    /// "2h", "3j", etc.
    var relativeDate: String? {
        guard let date = DateFormatters.iso8601(createdAt) else { return nil }
        return DateFormatters.relativeShort(date)
    }
}
