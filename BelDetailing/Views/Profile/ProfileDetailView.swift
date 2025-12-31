//
//  ProfileDetailView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import SafariServices

struct ProfileDetailView: View {
    @StateObject private var vm: ProfileDetailViewModel
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @Environment(\.dismiss) private var dismiss
    
    init(engine: Engine, user: User) {
        _vm = StateObject(wrappedValue: ProfileDetailViewModel(engine: engine, user: user))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header avec photo et nom
                    profileHeader
                    
                    // Métriques (Provider seulement)
                    if vm.user.role == .provider {
                        providerMetrics
                        
                        // Stripe Connect Card
                        stripeConnectCard
                        
                        // Champs manquants si nécessaire
                        if !vm.isProviderComplete {
                            missingFieldsCard
                        }
                    }
                    
                    // Sections selon le rôle
                    switch vm.user.role {
                    case .provider:
                        providerSections
                    case .company:
                        companySections
                    case .customer:
                        customerSections
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
            
            if vm.isLoading {
                Color.black.opacity(0.06).ignoresSafeArea()
                ProgressView()
            }
            
            if let toast = vm.toast {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { vm.toast = nil }
                
                CenterToast(toast: toast) { vm.toast = nil }
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .navigationTitle(R.string.localizable.profileDetailTitle())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditProfileView(engine: vm.engine, user: vm.user)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .task {
            await vm.load()
        }
        .sheet(isPresented: .constant(vm.safariURL != nil), onDismiss: { vm.safariURL = nil }) {
            if let url = vm.safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert(R.string.localizable.commonError(), isPresented: Binding(
            get: { vm.errorText != nil },
            set: { if !$0 { vm.errorText = nil } }
        )) {
            Button(R.string.localizable.commonOk()) { vm.errorText = nil }
        } message: {
            Text(vm.errorText ?? "")
        }
        .onAppear { tabBarVisibility.isHidden = true }
        // IMPORTANT: on supprime le onDisappear ici pour éviter de réafficher la tab bar
        // .onDisappear { tabBarVisibility.isHidden = false }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Photo de profil
            Group {
                if let url = vm.providerDetail?.logoURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            profilePlaceholder
                        }
                    }
                } else {
                    profilePlaceholder
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            // Nom et profession
            VStack(spacing: 6) {
                Text(vm.user.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                if vm.user.role == .provider, let companyName = vm.providerCompanyName.isEmpty ? nil : vm.providerCompanyName {
                    Text(companyName)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                } else if vm.user.role == .company, !vm.companyLegalName.isEmpty {
                    Text(vm.companyLegalName)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private var profilePlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
        }
    }
    
    // MARK: - Provider Metrics
    private var providerMetrics: some View {
        HStack(spacing: 0) {
            ProfileMetricCard(
                icon: "star.fill",
                value: formatRating(vm.providerRating),
                label: R.string.localizable.profileMetricRating(),
                iconColor: .yellow
            )
            
            Divider()
                .frame(height: 50)
            
            ProfileMetricCard(
                icon: "calendar",
                value: formatExperience(vm.providerExperience),
                label: R.string.localizable.profileMetricExperience(),
                iconColor: .blue
            )
            
            Divider()
                .frame(height: 50)
            
            ProfileMetricCard(
                icon: "person.3.fill",
                value: formatTeamSize(vm.providerTeamSize),
                label: R.string.localizable.profileMetricTeam(),
                iconColor: .green
            )
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func formatRating(_ rating: Double?) -> String {
        guard let rating = rating, rating > 0 else { return "—" }
        return String(format: "%.1f", rating)
    }
    
    private func formatExperience(_ years: Int?) -> String {
        guard let years = years, years > 0 else { return "—" }
        return "\(years) \(R.string.localizable.profileMetricYears())"
    }
    
    private func formatTeamSize(_ size: Int?) -> String {
        guard let size = size, size > 0 else { return "—" }
        return "\(size)"
    }
    
    // MARK: - Stripe Connect Card
    private var stripeConnectCard: some View {
        Button {
            Task {
                if vm.hasStripeAccount {
                    await vm.openStripeOnboarding()
                } else {
                    await vm.createStripeAccountIfNeeded()
                }
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "creditcard")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.hasStripeAccount ? R.string.localizable.profileStripeActivated() : R.string.localizable.profileStripeActivate())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(vm.hasStripeAccount ? R.string.localizable.profileStripeReady() : R.string.localizable.profileStripeCreateAccount())
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black)
            )
            .shadow(color: .black.opacity(0.25), radius: 14, y: 8)
        }
        .disabled(!vm.isProviderComplete)
        .opacity(vm.isProviderComplete ? 1 : 0.6)
    }
    
    // MARK: - Missing Fields Card
    private var missingFieldsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(R.string.localizable.profileMissingFieldsTitle())
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            ForEach(vm.providerMissingFields, id: \.self) { field in
                HStack(spacing: 8) {
                    Text("•")
                        .foregroundColor(.gray)
                    Text(field)
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }
    
    // MARK: - Provider Sections
    private var providerSections: some View {
        VStack(spacing: 20) {
            bioSection
            contactSection
            companySection
            locationSection
        }
    }
    
    // MARK: - Company Sections
    private var companySections: some View {
        VStack(spacing: 20) {
            contactSection
            companySection
            locationSection
        }
    }
    
    // MARK: - Customer Sections
    private var customerSections: some View {
        VStack(spacing: 20) {
            contactSection
            locationSection
        }
    }
    
    // MARK: - Bio Section
    private var bioSection: some View {
        ProfileSectionCard(title: R.string.localizable.profileSectionBio()) {
            Text(vm.providerBio.isEmpty ? "—" : vm.providerBio)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        ProfileSectionCard(title: R.string.localizable.profileSectionContact()) {
            VStack(spacing: 12) {
                InfoRow(
                    label: R.string.localizable.profileFieldEmail(),
                    value: vm.user.email
                )
                InfoRow(
                    label: R.string.localizable.profileFieldPhone(),
                    value: vm.phone.isEmpty ? "—" : vm.phone
                )
            }
        }
    }
    
    // MARK: - Company Section
    private var companySection: some View {
        ProfileSectionCard(title: R.string.localizable.profileSectionCompany()) {
            VStack(spacing: 12) {
                if vm.user.role == .provider {
                    InfoRow(
                        label: R.string.localizable.profileFieldCommercialName(),
                        value: vm.providerCompanyName.isEmpty ? "—" : vm.providerCompanyName
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldTeam(),
                        value: (vm.providerTeamSize ?? 0) > 0 ? "\(vm.providerTeamSize ?? 0)" : "—"
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldExperience(),
                        value: vm.providerYearsOfExperience > 0 ? "\(vm.providerYearsOfExperience) \(R.string.localizable.profileMetricYears())" : "—"
                    )
                } else if vm.user.role == .company {
                    InfoRow(
                        label: R.string.localizable.profileFieldVAT(),
                        value: vm.vatNumber.isEmpty ? "—" : vm.vatNumber
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldLegalName(),
                        value: vm.companyLegalName.isEmpty ? "—" : vm.companyLegalName
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldCompanyType(),
                        value: vm.companyTypeId.isEmpty ? "—" : vm.companyTypeId
                    )
                }
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        ProfileSectionCard(title: R.string.localizable.profileSectionLocation()) {
            VStack(spacing: 12) {
                if vm.user.role == .provider {
                    InfoRow(
                        label: R.string.localizable.profileFieldCity(),
                        value: vm.providerBaseCity.isEmpty ? "—" : vm.providerBaseCity
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldPostalCode(),
                        value: vm.providerPostalCode.isEmpty ? "—" : vm.providerPostalCode
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldMobileService(),
                        value: vm.providerHasMobileService ? R.string.localizable.commonYes() : R.string.localizable.commonNo()
                    )
                } else if vm.user.role == .company {
                    InfoRow(
                        label: R.string.localizable.profileFieldCity(),
                        value: vm.companyCity.isEmpty ? "—" : vm.companyCity
                    )
                    InfoRow(
                        label: R.string.localizable.profileFieldPostalCode(),
                        value: vm.companyPostalCode.isEmpty ? "—" : vm.companyPostalCode
                    )
                } else if vm.user.role == .customer {
                    InfoRow(
                        label: R.string.localizable.profileFieldAddress(),
                        value: vm.customerAddress.isEmpty ? "—" : vm.customerAddress
                    )
                }
            }
        }
    }
}

// MARK: - Metric Card Component (renamed to avoid clashes)
private struct ProfileMetricCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section Card Component (renamed and closure-based to match usage)
private struct ProfileSectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Info Row Component
private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.trailing)
        }
    }
}
