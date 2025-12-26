import Foundation

struct TaxSummary: Codable, Hashable {
    let month: String            // "2024-12"
    let revenue: Double          // 2450
    let servicesCount: Int       // 18
    let commissions: Double      // 245
    let net: Double              // 2205
    let currency: String         // "eur"
}

enum TaxDocumentType: String, Codable {
    case belDetailingInvoice     // facture commissions
    case stripeStatement         // relevé paiements
}

struct TaxDocument: Identifiable, Codable, Hashable {
    let id: String
    let type: TaxDocumentType
    let title: String            // "Facture BelDetailing"
    let subtitle: String         // "Décembre 2024 • Commission mensuelle"
    let amount: Double
    let currency: String
    let downloadUrl: String      // URL absolue (signed URL) ou backend
}
