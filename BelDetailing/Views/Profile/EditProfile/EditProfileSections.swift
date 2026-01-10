//
//  EditProfileSections.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Provider Sections
struct EditProfileProviderSections: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            EditProfileBioSection(viewModel: viewModel)
            EditProfileContactSection(viewModel: viewModel)
            EditProfileCompanySection(viewModel: viewModel)
            EditProfileLocationSection(viewModel: viewModel)
        }
    }
}

// MARK: - Company Sections
struct EditProfileCompanySections: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            EditProfileContactSection(viewModel: viewModel)
            EditProfileCompanySection(viewModel: viewModel)
            EditProfileLocationSection(viewModel: viewModel)
        }
    }
}

// MARK: - Customer Sections
struct EditProfileCustomerSections: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            EditProfileContactSection(viewModel: viewModel)
            EditProfileVehicleSection(viewModel: viewModel)
            EditProfileLocationSection(viewModel: viewModel)
        }
    }
}

// MARK: - Bio Section
struct EditProfileBioSection: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        SectionCard(title: R.string.localizable.profileSectionBio()) {
            TextField("Bio", text: $viewModel.providerBio, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(3...7)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Contact Section
struct EditProfileContactSection: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        SectionCard(title: R.string.localizable.profileSectionContact()) {
            ContactContent(viewModel: viewModel)
        }
    }
}

private struct ContactContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        switch viewModel.user.role {
        case .provider:
            ProviderContactContent(viewModel: viewModel)
        case .company, .customer:
            BasicContactContent(viewModel: viewModel)
        }
    }
}

private struct ProviderContactContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldEmail(),
                value: $viewModel.providerEmail,
                isEditable: true
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldPhone(),
                value: $viewModel.phone
            )
            EditableInfoRow(
                label: R.string.localizable.profileDetailOpeningHours(),
                value: $viewModel.providerOpeningHours
            )
        }
    }
}

private struct BasicContactContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldEmail(),
                value: $viewModel.providerEmail,
                isEditable: false
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldPhone(),
                value: $viewModel.phone
            )
        }
    }
}

// MARK: - Company Section
struct EditProfileCompanySection: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        SectionCard(title: R.string.localizable.profileSectionCompany()) {
            CompanyContent(viewModel: viewModel)
        }
    }
}

private struct CompanyContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        switch viewModel.user.role {
        case .provider:
            ProviderCompanyContent(viewModel: viewModel)
        case .company:
            CompanyCompanyContent(viewModel: viewModel)
        case .customer:
            CustomerCompanyContent(viewModel: viewModel)
        }
    }
}

private struct ProviderCompanyContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldCommercialName(),
                value: $viewModel.providerCompanyName
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldVAT(),
                value: $viewModel.vatNumber
            )
        }
    }
}

private struct CompanyCompanyContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldVAT(),
                value: $viewModel.vatNumber
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldLegalName(),
                value: $viewModel.companyLegalName
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldCompanyType(),
                value: $viewModel.companyTypeId
            )
            EditableInfoRow(
                label: R.string.localizable.profileDetailContactName(),
                value: $viewModel.companyContactName
            )
        }
    }
}

private struct CustomerCompanyContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldVAT(),
                value: $viewModel.vatNumber
            )
        }
    }
}

// MARK: - Location Section
struct EditProfileLocationSection: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        SectionCard(title: R.string.localizable.profileSectionLocation()) {
            LocationContent(viewModel: viewModel)
        }
    }
}

private struct LocationContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        switch viewModel.user.role {
        case .provider:
            ProviderLocationContent(viewModel: viewModel)
        case .company:
            CompanyLocationContent(viewModel: viewModel)
        case .customer:
            CustomerLocationContent(viewModel: viewModel)
        }
    }
}

private struct ProviderLocationContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldCity(),
                value: $viewModel.providerBaseCity
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldPostalCode(),
                value: $viewModel.providerPostalCode
            )
            Toggle(R.string.localizable.profileFieldMobileService(), isOn: $viewModel.providerHasMobileService)
                .padding(.vertical, 4)
            MinPriceControls(viewModel: viewModel)
            
            Divider()
                .padding(.vertical, 8)
            
            // Transport fees section
            // Note: Les frais de transport sont maintenant fixes (zones avec plafond 20€)
            // Le provider peut uniquement activer/désactiver le service à domicile
            VStack(alignment: .leading, spacing: 12) {
                Text(R.string.localizable.profileSectionTransport())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Toggle(R.string.localizable.profileFieldTransportEnabled(), isOn: $viewModel.providerTransportEnabled)
                    .padding(.vertical, 4)
            }
        }
    }
}

private struct CompanyLocationContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldCity(),
                value: $viewModel.companyCity
            )
            EditableInfoRow(
                label: R.string.localizable.profileFieldPostalCode(),
                value: $viewModel.companyPostalCode
            )
        }
    }
}

private struct CustomerLocationContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            EditableInfoRow(
                label: R.string.localizable.profileFieldAddress(),
                value: $viewModel.customerAddress
            )
        }
    }
}

// MARK: - Vehicle Section (Customer only)
struct EditProfileVehicleSection: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        SectionCard(title: R.string.localizable.profileSectionVehicle()) {
            VehicleTypePicker(selectedVehicleType: $viewModel.customerVehicleType)
        }
    }
}

private struct VehicleTypePicker: View {
    @Binding var selectedVehicleType: VehicleType?
    
    var body: some View {
        VStack(spacing: 12) {
            Menu {
                ForEach(VehicleType.allCases) { vehicleType in
                    Button {
                        selectedVehicleType = vehicleType
                    } label: {
                        HStack {
                            Image(systemName: vehicleType.icon)
                            Text(vehicleType.localizedName)
                            if selectedVehicleType == vehicleType {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if let selected = selectedVehicleType {
                        Image(systemName: selected.icon)
                            .foregroundColor(.black)
                        Text(selected.localizedName)
                            .foregroundColor(.black)
                    } else {
                        Text(R.string.localizable.profileFieldVehicleTypePlaceholder())
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            if selectedVehicleType == nil {
                Text(R.string.localizable.profileFieldVehicleTypeRequired())
                    .font(.system(size: 13))
                    .foregroundColor(.orange)
            }
        }
    }
}

private struct MinPriceControls: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        HStack {
            Button {
                viewModel.providerMinPrice = max(0, viewModel.providerMinPrice - 5)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.black)
            }
            Text("€\(Int(viewModel.providerMinPrice))")
                .font(.system(size: 18, weight: .semibold))
                .frame(minWidth: 80)
            Button {
                viewModel.providerMinPrice += 5
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black)
            }
            Spacer()
            Text(R.string.localizable.profileFieldMinPrice())
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
