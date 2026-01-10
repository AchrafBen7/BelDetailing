//
//  EditProfileView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var logoPhotoItem: PhotosPickerItem?
    @State private var bannerPhotoItem: PhotosPickerItem?
    @State private var localLogoImage: UIImage?
    @State private var localBannerImage: UIImage?
    
    init(engine: Engine, user: User) {
        // Build the VM first, then wrap it — this often helps the type checker.
        let vm = EditProfileViewModel(engine: engine, user: user)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            // Fond global clair
            Color(R.color.mainBackground.name)
                .ignoresSafeArea()
                // Bande noire qui va jusqu'en haut (sous la status bar)
                .overlay(
                    Color.black
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top),
                    alignment: .top
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header noir
                    header
                    
                    // Contenu
                    EditProfileContent(
                        viewModel: viewModel,
                        logoPhotoItem: $logoPhotoItem,
                        localLogoImage: $localLogoImage
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            
            SavingOverlay(isSaving: viewModel.isSaving)
            ToastOverlay(toast: viewModel.toast) { viewModel.toast = nil }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(R.string.localizable.commonError(), isPresented: errorAlertBinding) {
            Button(R.string.localizable.commonOk()) { viewModel.errorText = nil }
        } message: {
            Text(viewModel.errorText ?? "")
        }
        .onChange(of: logoPhotoItem) { _, _ in
            Task { await loadSelectedLogo() }
        }
        .onChange(of: bannerPhotoItem) { _, _ in
            Task { await loadSelectedBanner() }
        }
        .onAppear {
            withAnimation(.easeInOut) { tabBarVisibility.isHidden = true }
        }
        .onDisappear {
            withAnimation(.easeInOut) { tabBarVisibility.isHidden = false }
        }
    }
    
    // MARK: - Header noir
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                
                Spacer()
                
                Button {
                    Task {
                        let ok = await viewModel.save()
                        if ok {
                            dismiss()
                        }
                    }
                } label: {
                    Text(R.string.localizable.commonSave())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.canSave ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.canSave ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.canSave)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(R.string.localizable.profileEditTitle())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
        .padding(.bottom, 1)
    }
    
    // MARK: - Computed bindings
    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorText != nil },
            set: { if !$0 { viewModel.errorText = nil } }
        )
    }
    
    // MARK: - Load Selected Images
    private func loadSelectedLogo() async {
        guard let item = logoPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            await MainActor.run {
                localLogoImage = img
                viewModel.selectedLogoData = data
            }
        }
    }
    
    private func loadSelectedBanner() async {
        guard let item = bannerPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            await MainActor.run {
                localBannerImage = img
                viewModel.selectedBannerData = data
            }
        }
    }
}

// MARK: - Small extracted subviews to ease type checking
private struct SavingOverlay: View {
    let isSaving: Bool
    var body: some View {
        Group {
            if isSaving {
                Color.black.opacity(0.06).ignoresSafeArea()
                ProgressView()
            }
        }
    }
}

private struct ToastOverlay: View {
    let toast: ToastState?
    let onClose: () -> Void
    var body: some View {
        Group {
            if let toast {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { onClose() }
                
                CenterToast(toast: toast, onClose: onClose)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
    }
}

private struct SaveButton: View {
    let canSave: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(R.string.localizable.commonSave())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(canSave ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(canSave ? Color.blue : Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!canSave)
    }
}

// MARK: - Extracted content to reduce type-checking depth in parent
private struct EditProfileContent: View {
    @ObservedObject var viewModel: EditProfileViewModel
    @Binding var logoPhotoItem: PhotosPickerItem?
    @Binding var localLogoImage: UIImage?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header avec photo et nom
            AnyView(
                EditProfileHeaderView(
                    viewModel: viewModel,
                    logoPhotoItem: $logoPhotoItem,
                    localLogoImage: $localLogoImage
                )
            )
            
            // Métriques (Provider seulement) - Read-only
            if viewModel.user.role == .provider {
                AnyView(EditProfileMetricsView(viewModel: viewModel))
            }
            
            // Sections selon le rôle
            roleSections
        }
    }
    
    // Erase differing branch types to keep inference shallow
    private var roleSections: some View {
        Group {
            switch viewModel.user.role {
            case .provider:
                AnyView(EditProfileProviderSections(viewModel: viewModel))
            case .company:
                AnyView(EditProfileCompanySections(viewModel: viewModel))
            case .customer:
                AnyView(EditProfileCustomerSections(viewModel: viewModel))
            }
        }
    }
}
