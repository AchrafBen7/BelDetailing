//
//  ProfileDetailView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//  Updated: Design minimaliste blanc/noir style Uber avec Design System
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
            // Fond blanc
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header simple
                header
                
                // Contenu scrollable
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Photo de profil
                        profilePictureSection
                        
                        // Informations principales
                        mainInfoSection
                        
                        // Sections selon le rôle
                        roleSpecificSections
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
            
            // Loading overlay
            if vm.isLoading {
                Color.black.opacity(0.06)
                    .ignoresSafeArea()
                ProgressView()
            }
            
            // Toast overlay
            if let toast = vm.toast {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { vm.toast = nil }
                
                CenterToast(toast: toast) { vm.toast = nil }
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await vm.load()
        }
        .sheet(isPresented: .constant(vm.safariURL != nil), onDismiss: { vm.safariURL = nil }) {
            if let url = vm.safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert(
            R.string.localizable.errorGenericTitle(),
            isPresented: Binding(
                get: { vm.errorText != nil },
                set: { if !$0 { vm.errorText = nil } }
            )
        ) {
            Button(R.string.localizable.commonOk()) {
                vm.errorText = nil
            }
        } message: {
            if let error = vm.errorText {
                Text(error)
            }
        }
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
    
    // MARK: - Header Simple
    
    private var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Bouton retour
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Titre
            Text(R.string.localizable.profileDetailTitle())
                .font(DesignSystem.Typography.navigationTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Spacer()
            
            // Bouton Edit
            NavigationLink {
                EditProfileView(engine: vm.engine, user: vm.user)
            } label: {
                Image(systemName: "pencil")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.cardBackground)
    }
    
    // MARK: - Photo de Profil
    
    private var profilePictureSection: some View {
        ProfilePictureSection(
            displayName: vm.user.displayName,
            companyName: vm.user.role == .provider ? vm.providerCompanyName : (vm.user.role == .company ? vm.companyLegalName : nil),
            role: vm.user.role,
            logoURL: vm.providerDetail?.logoURL
        )
    }
    
    // MARK: - Informations Principales
    
    private var mainInfoSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Email
            SimpleInfoRow(
                label: R.string.localizable.profileFieldEmail(),
                value: vm.user.email
            )
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Téléphone
            SimpleInfoRow(
                label: R.string.localizable.profileFieldPhone(),
                value: vm.phone.isEmpty ? "—" : vm.phone
            )
        }
        .cardStyle(
            padding: DesignSystem.Spacing.md,
            cornerRadius: DesignSystem.CornerRadius.medium
        )
    }
    
    // MARK: - Sections selon le rôle
    
    @ViewBuilder
    private var roleSpecificSections: some View {
        switch vm.user.role {
        case .provider:
            ProviderRoleSections(
                viewModel: vm,
                stripeCard: AnyView(stripeConnectCard),
                missingFieldsCard: AnyView(missingFieldsCard)
            )
        case .company:
            CompanyRoleSections(viewModel: vm)
        case .customer:
            CustomerRoleSections(viewModel: vm, engine: vm.engine)
        }
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
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "creditcard")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 48, height: 48)
                    .background(DesignSystem.Colors.border)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(vm.hasStripeAccount ? R.string.localizable.profileStripeActivated() : R.string.localizable.profileStripeActivate())
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(vm.hasStripeAccount ? R.string.localizable.profileStripeReady() : R.string.localizable.profileStripeCreateAccount())
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .padding(DesignSystem.Spacing.md)
            .cardStyle(
                padding: DesignSystem.Spacing.md,
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        }
        .disabled(!vm.isProviderComplete)
        .opacity(vm.isProviderComplete ? 1 : 0.6)
    }
    
    // MARK: - Missing Fields Card
    
    private var missingFieldsCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(R.string.localizable.profileMissingFieldsTitle())
                .font(DesignSystem.Typography.bodyBold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            ForEach(vm.providerMissingFields, id: \.self) { field in
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("•")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text(field)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .cardStyle(
            padding: DesignSystem.Spacing.md,
            cornerRadius: DesignSystem.CornerRadius.medium
        )
    }
}


