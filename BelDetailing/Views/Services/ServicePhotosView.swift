//
//  ServicePhotosView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct ServicePhotosView: View {
    let serviceId: String
    let engine: Engine
    let isOwnService: Bool // Si true, permet l'ajout/suppression
    
    @StateObject private var viewModel: ServicePhotosViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPhoto = false
    @State private var selectedPhoto: ServicePhoto?
    
    init(serviceId: String, engine: Engine, isOwnService: Bool = false) {
        self.serviceId = serviceId
        self.engine = engine
        self.isOwnService = isOwnService
        _viewModel = StateObject(wrappedValue: ServicePhotosViewModel(serviceId: serviceId, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.photos.isEmpty {
                    EmptyStateView(
                        title: "Aucune photo",
                        message: isOwnService ? "Ajoutez des photos pour ce service" : "Ce service n'a pas encore de photos",
                        systemIcon: "photo.on.rectangle.angled"
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.photos) { photo in
                                ServicePhotoCard(
                                    photo: photo,
                                    onTap: {
                                        selectedPhoto = photo
                                    },
                                    onDelete: isOwnService ? {
                                        Task {
                                            await viewModel.deletePhoto(photoId: photo.id)
                                        }
                                    } : nil
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Photos du service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                
                if isOwnService {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddPhoto = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                        .disabled(viewModel.photos.count >= 5)
                    }
                }
            }
            .sheet(isPresented: $showAddPhoto) {
                AddServicePhotoView(
                    serviceId: serviceId,
                    engine: engine,
                    onPhotoAdded: {
                        Task {
                            await viewModel.loadPhotos()
                        }
                    }
                )
            }
            .sheet(item: $selectedPhoto) { photo in
                ServicePhotoDetailView(photo: photo)
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
            .task {
                await viewModel.loadPhotos()
            }
        }
    }
}

// MARK: - Service Photo Card

private struct ServicePhotoCard: View {
    let photo: ServicePhoto
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(urlString: photo.thumbnailUrl ?? photo.imageUrl, useThumbnail: true) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .overlay(ProgressView())
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Service Photo Detail View

private struct ServicePhotoDetailView: View {
    let photo: ServicePhoto
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                CachedAsyncImage(urlString: photo.imageUrl, useThumbnail: false) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationTitle(photo.caption ?? "Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

