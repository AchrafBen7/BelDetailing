//
//  AddServicePhotoView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import PhotosUI
import RswiftResources

struct AddServicePhotoView: View {
    let serviceId: String
    let engine: Engine
    let onPhotoAdded: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddServicePhotoViewModel
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    
    init(serviceId: String, engine: Engine, onPhotoAdded: @escaping () -> Void) {
        self.serviceId = serviceId
        self.engine = engine
        self.onPhotoAdded = onPhotoAdded
        _viewModel = StateObject(wrappedValue: AddServicePhotoViewModel(serviceId: serviceId, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Image picker
                    imagePickerSection
                    
                    // Caption
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Légende (optionnel)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        
                        TextField("Ex: Avant/Après", text: $caption)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Submit button
                    Button {
                        Task {
                            let success = await viewModel.addPhoto(
                                image: selectedImage,
                                caption: caption.isEmpty ? nil : caption
                            )
                            if success {
                                onPhotoAdded()
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Ajouter la photo")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedImage != nil && !viewModel.isUploading ? Color.black : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedImage == nil || viewModel.isUploading)
                }
                .padding(20)
            }
            .navigationTitle("Ajouter une photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            .alert("Erreur", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let msg = viewModel.errorMessage {
                    Text(msg)
                }
            }
        }
    }
    
    private var imagePickerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 300)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Choisir une photo")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            
            PhotosPicker(selection: $photoItem, matching: .images) {
                HStack {
                    Image(systemName: selectedImage == nil ? "plus.circle.fill" : "arrow.clockwise")
                    Text(selectedImage == nil ? "Choisir une photo" : "Remplacer")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class AddServicePhotoViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    private let serviceId: String
    private let engine: Engine
    private let uploader: OptimizedImageUploader
    
    init(serviceId: String, engine: Engine) {
        self.serviceId = serviceId
        self.engine = engine
        self.uploader = OptimizedImageUploader(mediaService: engine.mediaService)
    }
    
    func addPhoto(image: UIImage?, caption: String?) async -> Bool {
        guard let image = image else {
            errorMessage = "Veuillez sélectionner une photo"
            return false
        }
        
        isUploading = true
        errorMessage = nil
        
        // Upload optimisé (thumbnail + full)
        let uploadResult = await uploader.uploadOptimizedImage(image: image)
        
        guard case .success(let urls) = uploadResult else {
            if case .failure(let error) = uploadResult {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Erreur lors de l'upload"
            }
            isUploading = false
            return false
        }
        
        // Ajouter la photo au service
        let addResult = await engine.servicePhotoService.addPhoto(
            serviceId: serviceId,
            imageUrl: urls.fullUrl,
            thumbnailUrl: urls.thumbnailUrl,
            caption: caption
        )
        
        isUploading = false
        
        switch addResult {
        case .success:
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }
}

