//
//  EditProfileHeaderView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import PhotosUI
import RswiftResources

struct EditProfileHeaderView: View {
    @ObservedObject var viewModel: EditProfileViewModel
    @Binding var logoPhotoItem: PhotosPickerItem?
    @Binding var localLogoImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            AvatarBlock(
                localLogoImage: localLogoImage,
                remoteURLString: viewModel.providerLogoUrl,
                logoPhotoItem: $logoPhotoItem
            )
            
            NameCompanyBlock(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

private struct AvatarBlock: View {
    let localLogoImage: UIImage?
    let remoteURLString: String?
    @Binding var logoPhotoItem: PhotosPickerItem?
    
    var body: some View {
        AvatarContent(localLogoImage: localLogoImage, remoteURLString: remoteURLString)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .overlay(alignment: .bottomTrailing) {
                PhotosPicker(selection: $logoPhotoItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
    }
}

private struct AvatarContent: View {
    let localLogoImage: UIImage?
    let remoteURLString: String?
    
    var body: some View {
        Group {
            if let img = localLogoImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else if let urlString = remoteURLString,
                      let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder()
                    }
                }
            } else {
                placeholder()
            }
        }
    }
    
    @ViewBuilder
    private func placeholder() -> some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
        }
    }
}

private struct NameCompanyBlock: View {
    @ObservedObject var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 6) {
            if viewModel.user.role == .provider {
                AnyView(
                    TextField("", text: $viewModel.providerDisplayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                )
            } else {
                AnyView(
                    Text(viewModel.user.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                )
            }
            
            if viewModel.user.role == .provider, !viewModel.providerCompanyName.isEmpty {
                AnyView(
                    TextField("", text: $viewModel.providerCompanyName)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                )
            } else if viewModel.user.role == .company, !viewModel.companyLegalName.isEmpty {
                AnyView(
                    Text(viewModel.companyLegalName)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                )
            }
        }
    }
}
