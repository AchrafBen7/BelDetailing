//
//  ProfileDetailViewModel.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation
import Combine
import SwiftUI
import RswiftResources

@MainActor
final class ProfileDetailViewModel: ObservableObject {
    // INPUT
    let engine: Engine
    @Published var user: User
    
    // UI State
    @Published var isLoading = false
    @Published var errorText: String?
    @Published var toast: ToastState?
    
    // Provider extra data
    @Published var providerDetail: Detailer?
    @Published var providerStats: DetailerStats?
    @Published var stripeStatus: StripeAccountStatus?
    @Published var safariURL: URL?
    
    // MARK: - Form fields (COMMON)
    @Published var phone: String = ""
    @Published var vatNumber: String = ""
    
    // CUSTOMER
    @Published var customerFirstName: String = ""
    @Published var customerLastName: String = ""
    @Published var customerAddress: String = ""
    
    // COMPANY
    @Published var companyLegalName: String = ""
    @Published var companyTypeId: String = ""
    @Published var companyCity: String = ""
    @Published var companyPostalCode: String = ""
    @Published var companyContactName: String = ""
    
    // PROVIDER
    @Published var providerDisplayName: String = ""
    @Published var providerBio: String = ""
    @Published var providerBaseCity: String = ""
    @Published var providerPostalCode: String = ""
    @Published var providerHasMobileService: Bool = false
    @Published var providerMinPrice: Double = 0
    @Published var providerServices: [String] = []
    @Published var providerCompanyName: String = ""
    @Published var providerYearsOfExperience: Int = 0
    
    init(engine: Engine, user: User) {
        self.engine = engine
        self.user = user
        hydrateFromUser(user)
    }
    
    func hydrateFromUser(_ user: User) {
        phone = user.phone ?? ""
        vatNumber = user.vatNumber ?? ""
        
        if let customer = user.customerProfile {
            customerFirstName = customer.firstName
            customerLastName = customer.lastName
            customerAddress = customer.defaultAddress ?? ""
        }
        
        if let company = user.companyProfile {
            companyLegalName = company.legalName
            companyTypeId = company.companyTypeId
            companyCity = company.city ?? ""
            companyPostalCode = company.postalCode ?? ""
            companyContactName = company.contactName ?? ""
        }
        
        if let provider = user.providerProfile {
            providerDisplayName = provider.displayName
            providerBio = provider.bio ?? ""
            providerBaseCity = provider.baseCity ?? ""
            providerPostalCode = provider.postalCode ?? ""
            providerHasMobileService = provider.hasMobileService
            providerMinPrice = provider.minPrice ?? 0
            providerServices = provider.services ?? []
        }
    }
    
    // MARK: - Load Data
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Refresh user data
        await refreshUser()
        
        // Load role-specific data
        switch user.role {
        case .provider:
            await loadProviderData()
        case .company, .customer:
            break
        }
    }
    
    private func loadProviderData() async {
        // Load provider detail (with stats like rating, experience, team size)
        // Use user.id as provider ID (they should be the same for logged-in provider)
        let detailResult = await engine.detailerService.getProfile(id: user.id)
        if case .success(let detail) = detailResult {
            providerDetail = detail
            providerCompanyName = detail.companyName ?? ""
            providerYearsOfExperience = detail.yearsOfExperience
        }
        
        // Load provider stats
        let statsResult = await engine.detailerService.getMyStats()
        if case .success(let stats) = statsResult {
            providerStats = stats
        }
        
        // Load Stripe status
        await loadStripeStatus()
    }
    
    func refreshUser() async {
        let res = await engine.userService.me()
        switch res {
        case .success(let fresh):
            StorageManager.shared.saveUser(fresh)
            user = fresh
            hydrateFromUser(fresh)
        case .failure(let err):
            errorText = err.localizedDescription
        }
    }
    
    func loadStripeStatus() async {
        guard user.role == .provider else { return }
        let statusResult = await engine.stripeConnectService.accountStatus()
        if case let .success(status) = statusResult {
            stripeStatus = status
        }
    }
    
    // MARK: - Provider Completeness
    var providerMissingFields: [String] {
        guard user.role == .provider else { return [] }
        var missing: [String] = []
        
        if phone.trimmed.isEmpty { missing.append(R.string.localizable.profileFieldPhone()) }
        if vatNumber.trimmed.isEmpty { missing.append(R.string.localizable.profileFieldVAT()) }
        if providerDisplayName.trimmed.isEmpty { missing.append(R.string.localizable.profileFieldDisplayName()) }
        if providerBaseCity.trimmed.isEmpty { missing.append(R.string.localizable.profileFieldCity()) }
        if providerPostalCode.trimmed.isEmpty { missing.append(R.string.localizable.profileFieldPostalCode()) }
        if providerMinPrice <= 0 { missing.append(R.string.localizable.profileFieldMinPrice()) }
        
        return missing
    }
    
    var isProviderComplete: Bool {
        providerMissingFields.isEmpty
    }
    
    var hasStripeAccount: Bool {
        stripeStatus != nil && stripeStatus?.chargesEnabled == true
    }
    
    var needsStripeAccount: Bool {
        user.role == .provider && !hasStripeAccount
    }
    
    // MARK: - Provider Metrics
    var providerRating: Double? {
        providerDetail?.rating ?? providerStats?.rating
    }
    
    var providerExperience: Int? {
        providerDetail?.yearsOfExperience
    }
    
    var providerTeamSize: Int? {
        providerDetail?.teamSize
    }
    
    // MARK: - Stripe Actions
    func createStripeAccountIfNeeded() async {
        guard user.role == .provider else { return }
        guard isProviderComplete else {
            toast = ToastState(message: R.string.localizable.profileStripeIncompleteFields(), kind: .error)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let creationResult = await engine.stripeConnectService.createOrGetAccount()
        switch creationResult {
        case .success:
            await loadStripeStatus()
            toast = ToastState(message: R.string.localizable.profileStripeAccountCreated(), kind: .success)
        case .failure(let error):
            errorText = error.localizedDescription
        }
    }
    
    func openStripeOnboarding() async {
        guard user.role == .provider else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let linkResult = await engine.stripeConnectService.onboardingLink()
        switch linkResult {
        case .success(let payload):
            if let url = URL(string: payload.url) {
                safariURL = url
            }
        case .failure(let error):
            errorText = error.localizedDescription
        }
    }
}

// MARK: - Helpers
private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nilIfEmpty: String? {
        let trimmedValue = trimmed
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
