import Foundation

// MARK: - Models

struct StripeAccountStatus: Codable, Equatable {
    let id: String
    let chargesEnabled: Bool
    let payoutsEnabled: Bool
    let email: String?
    let businessType: String?
    let requirements: StripeRequirements

    struct StripeRequirements: Codable, Equatable {
        let currentlyDue: [String]
        let eventuallyDue: [String]
        let pastDue: [String]
    }
}

struct StripePayoutSummary: Codable, Equatable {
    struct BalanceAmount: Codable, Equatable {
        let amount: Int
        let currency: String
    }
    struct Payout: Codable, Equatable, Identifiable {
        let id: String
        let amount: Int
        let currency: String
        let arrivalDate: Int?
        let status: String?
        let description: String?
    }

    let available: [BalanceAmount]
    let pending: [BalanceAmount]
    let payouts: [Payout]
}

struct StripeCreateAccountResponse: Codable, Equatable {
    let stripeAccountId: String
    let created: Bool
}

struct StripeOnboardingLinkResponse: Codable, Equatable {
    let url: String
}

// MARK: - Protocol

protocol StripeConnectService {
    func createOrGetAccount() async -> APIResponse<StripeCreateAccountResponse>
    func onboardingLink() async -> APIResponse<StripeOnboardingLinkResponse>
    func accountStatus() async -> APIResponse<StripeAccountStatus>
    func payoutsSummary() async -> APIResponse<StripePayoutSummary>
}

// MARK: - Network Implementation

final class StripeConnectServiceNetwork: StripeConnectService {
    private let networkClient: NetworkClient
    init(networkClient: NetworkClient) { self.networkClient = networkClient }

    func createOrGetAccount() async -> APIResponse<StripeCreateAccountResponse> {
        await networkClient.call(endPoint: .stripeConnectCreateAccount)
    }

    func onboardingLink() async -> APIResponse<StripeOnboardingLinkResponse> {
        await networkClient.call(endPoint: .stripeConnectOnboardingLink)
    }

    func accountStatus() async -> APIResponse<StripeAccountStatus> {
        await networkClient.call(endPoint: .stripeConnectAccountStatus)
    }

    func payoutsSummary() async -> APIResponse<StripePayoutSummary> {
        await networkClient.call(endPoint: .stripeConnectPayoutsSummary)
    }
}
