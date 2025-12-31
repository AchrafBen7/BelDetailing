import Foundation

struct ProviderProfileDetail: Codable, Equatable {
    let userId: String
    let displayName: String
    let bio: String?
    let baseCity: String?
    let postalCode: String?
    let hasMobileService: Bool
    let minPrice: Double?
    let rating: Double?
    let services: [String]?
    let createdAt: String?
    let companyName: String?
    let lat: Double?
    let lng: Double?
    let reviewCount: Int?
    let teamSize: Int?
    let yearsOfExperience: Int?
    let logoUrl: String?
    let bannerUrl: String?
    let stripeAccountId: String?
    let stripeOnboardingCompleted: Bool?
    let phone: String?
    let email: String?
    let openingHours: String?
}
