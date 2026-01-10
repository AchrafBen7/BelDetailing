//
//  ProfileDetailSections.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Provider Sections
struct ProfileDetailProviderSections: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProfileDetailBioSection(vm: vm)
            ProfileDetailContactSection(vm: vm)
            ProfileDetailCompanySection(vm: vm)
            ProfileDetailLocationSection(vm: vm)
        }
    }
}

// MARK: - Company Sections
struct ProfileDetailCompanySections: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProfileDetailContactSection(vm: vm)
            ProfileDetailCompanySection(vm: vm)
            ProfileDetailLocationSection(vm: vm)
        }
    }
}

// MARK: - Customer Sections
struct ProfileDetailCustomerSections: View {
    @ObservedObject var vm: ProfileDetailViewModel
    let engine: Engine
    @State private var showVehicleProfile = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Bouton pour accéder au profil véhicule
            if let vehicleType = vm.user.customerProfile?.vehicleType {
                Button {
                    showVehicleProfile = true
                } label: {
                    HStack {
                        Image(systemName: vehicleType.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Mon Véhicule")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            ProfileDetailContactSection(vm: vm)
            ProfileDetailLocationSection(vm: vm)
        }
        .sheet(isPresented: $showVehicleProfile) {
            if let vehicleType = vm.user.customerProfile?.vehicleType {
                VehicleProfileViewWrapper(
                    customerId: vm.user.id,
                    vehicleType: vehicleType,
                    engine: engine
                )
            }
        }
    }
}

// MARK: - Vehicle Profile View Wrapper
struct VehicleProfileViewWrapper: View {
    let customerId: String
    let vehicleType: VehicleType
    let engine: Engine
    
    @StateObject private var viewModel: VehicleProfileViewModel
    
    init(customerId: String, vehicleType: VehicleType, engine: Engine) {
        self.customerId = customerId
        self.vehicleType = vehicleType
        self.engine = engine
        _viewModel = StateObject(wrappedValue: VehicleProfileViewModel(
            customerId: customerId,
            vehicleType: vehicleType,
            engine: engine
        ))
    }
    
    var body: some View {
        Group {
            if let profile = viewModel.vehicleProfile {
                VehicleProfileView(vehicleProfile: profile, engine: engine)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Erreur lors du chargement")
                    .foregroundColor(.gray)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Bio Section
struct ProfileDetailBioSection: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
        ProfileSectionCard(title: R.string.localizable.profileSectionBio()) {
            Text(vm.providerBio.isEmpty ? "—" : vm.providerBio)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Contact Section
struct ProfileDetailContactSection: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
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
}

// MARK: - Company Section
struct ProfileDetailCompanySection: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
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
}

// MARK: - Location Section
struct ProfileDetailLocationSection: View {
    @ObservedObject var vm: ProfileDetailViewModel
    
    var body: some View {
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

