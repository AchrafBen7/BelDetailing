//
//  ProfileDetailRoleSections.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//  Sections selon le rôle extraites de ProfileDetailView pour respecter la limite de longueur
//

import SwiftUI
import RswiftResources

// MARK: - Provider Sections Component

struct ProviderRoleSections: View {
    let viewModel: ProfileDetailViewModel
    let stripeCard: AnyView
    let missingFieldsCard: AnyView
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if !viewModel.providerBio.isEmpty {
                SimpleSectionCard(title: R.string.localizable.profileSectionBio()) {
                    Text(viewModel.providerBio)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if !viewModel.providerCompanyName.isEmpty || viewModel.providerTeamSize ?? 0 > 0 || viewModel.providerYearsOfExperience > 0 {
                SimpleSectionCard(title: R.string.localizable.profileSectionCompany()) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        if !viewModel.providerCompanyName.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldCommercialName(),
                                value: viewModel.providerCompanyName
                            )
                        }
                        if (viewModel.providerTeamSize ?? 0) > 0 {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldTeam(),
                                value: "\(viewModel.providerTeamSize ?? 0)"
                            )
                        }
                        if viewModel.providerYearsOfExperience > 0 {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldExperience(),
                                value: "\(viewModel.providerYearsOfExperience) \(R.string.localizable.profileMetricYears())"
                            )
                        }
                    }
                }
            }
            
            if !viewModel.providerBaseCity.isEmpty || !viewModel.providerPostalCode.isEmpty {
                SimpleSectionCard(title: R.string.localizable.profileSectionLocation()) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        if !viewModel.providerBaseCity.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldCity(),
                                value: viewModel.providerBaseCity
                            )
                        }
                        if !viewModel.providerPostalCode.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldPostalCode(),
                                value: viewModel.providerPostalCode
                            )
                        }
                        SimpleInfoRow(
                            label: R.string.localizable.profileFieldMobileService(),
                            value: viewModel.providerHasMobileService ? R.string.localizable.commonYes() : R.string.localizable.commonNo()
                        )
                    }
                }
            }
            
            if viewModel.needsStripeAccount || viewModel.hasStripeAccount {
                stripeCard
            }
            
            if !viewModel.isProviderComplete {
                missingFieldsCard
            }
        }
    }
}

// MARK: - Company Sections Component

struct CompanyRoleSections: View {
    let viewModel: ProfileDetailViewModel
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if !viewModel.companyLegalName.isEmpty || !viewModel.vatNumber.isEmpty {
                SimpleSectionCard(title: R.string.localizable.profileSectionCompany()) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        if !viewModel.vatNumber.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldVAT(),
                                value: viewModel.vatNumber
                            )
                        }
                        if !viewModel.companyLegalName.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldLegalName(),
                                value: viewModel.companyLegalName
                            )
                        }
                        if !viewModel.companyTypeId.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldCompanyType(),
                                value: viewModel.companyTypeId
                            )
                        }
                    }
                }
            }
            
            if !viewModel.companyCity.isEmpty || !viewModel.companyPostalCode.isEmpty {
                SimpleSectionCard(title: R.string.localizable.profileSectionLocation()) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        if !viewModel.companyCity.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldCity(),
                                value: viewModel.companyCity
                            )
                        }
                        if !viewModel.companyPostalCode.isEmpty {
                            SimpleInfoRow(
                                label: R.string.localizable.profileFieldPostalCode(),
                                value: viewModel.companyPostalCode
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Customer Sections Component

struct CustomerRoleSections: View {
    let viewModel: ProfileDetailViewModel
    let engine: Engine
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let vehicleType = viewModel.user.customerProfile?.vehicleType {
                NavigationLink {
                    VehicleProfileViewWrapper(
                        customerId: viewModel.user.id,
                        vehicleType: vehicleType,
                        engine: engine
                    )
                } label: {
                    HStack {
                        Image(systemName: vehicleType.icon)
                            .font(.system(size: 20))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .frame(width: 24, height: 24)
                        
                        Text("Mon Véhicule")
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

