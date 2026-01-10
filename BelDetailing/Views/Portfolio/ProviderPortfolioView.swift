//
//  ProviderPortfolioView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct ProviderPortfolioView: View {
    let providerId: String
    let engine: Engine
    let isOwnProfile: Bool // Si true, permet l'ajout/suppression
    
    @StateObject private var viewModel: ProviderPortfolioViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPhoto = false
    @State private var selectedPhoto: PortfolioPhoto?
    
    init(providerId: String, engine: Engine, isOwnProfile: Bool = false) {
        self.providerId = providerId
        self.engine = engine
        self.isOwnProfile = isOwnProfile
        _viewModel = StateObject(wrappedValue: ProviderPortfolioViewModel(providerId: providerId, engine: engine))
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
                        message: isOwnProfile ? "Ajoutez des photos de vos travaux précédents" : "Ce provider n'a pas encore de photos",
                        systemIcon: "photo.on.rectangle.angled"
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.photos) { photo in
                                PortfolioPhotoCard(
                                    photo: photo,
                                    onTap: {
                                        selectedPhoto = photo
                                    },
                                    onDelete: isOwnProfile ? {
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
            .navigationTitle("Portfolio")
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
                
                if isOwnProfile {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddPhoto = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                        .disabled(viewModel.photos.count >= 10)
                    }
                }
            }
            .sheet(isPresented: $showAddPhoto) {
                AddPortfolioPhotoView(
                    providerId: providerId,
                    engine: engine,
                    onPhotoAdded: {
                        Task {
                            await viewModel.loadPhotos()
                        }
                    }
                )
            }
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
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

// MARK: - Portfolio Photo Card

private struct PortfolioPhotoCard: View {
    let photo: PortfolioPhoto
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

// MARK: - Photo Detail View

private struct PhotoDetailView: View {
    let photo: PortfolioPhoto
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

