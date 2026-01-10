//
//  CreateReviewView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct CreateReviewView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: CreateReviewViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var selectedRating: Int = 0
    @State private var selectedCategories: Set<String> = []
    @State private var showSuccessAlert = false
    
    // Catégories de service (comme dans la photo)
    private let serviceCategories = [
        ("Cleanliness", "sparkles", "Nettoyage"),
        ("Music", "music.note", "Musique"),
        ("Air Freshner", "airpods", "Parfum d'air"),
        ("Punctuality", "clock", "Ponctualité"),
        ("Communication", "message", "Communication"),
        ("Quality", "star.fill", "Qualité")
    ]
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CreateReviewViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Fond clair
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header avec illustration de fond
                headerWithIllustration
                
                // Contenu principal
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Photo du provider
                        providerPhotoSection
                        
                        // Question
                        questionSection
                        
                        // Étoiles dans boîte blanche
                        ratingBoxSection
                        
                        // Catégories de service
                        categoriesSection
                        
                        // Bouton Submit
                        submitButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.06).ignoresSafeArea()
                ProgressView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Avis envoyé", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Merci pour votre avis !")
        }
        .alert("Erreur", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
    
    // MARK: - Header avec illustration
    
    private var headerWithIllustration: some View {
        ZStack(alignment: .top) {
            // Illustration de fond (voiture sur route)
            VStack(spacing: 0) {
                // Fond avec illustration stylisée
                ZStack {
                    // Fond dégradé (bleu clair vers vert foncé)
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.95, blue: 1.0), // Bleu clair
                            Color(red: 0.1, green: 0.4, blue: 0.2)   // Vert foncé
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Illustration simplifiée de voiture sur route
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            // Voiture stylisée
                            Image(systemName: "car.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            Spacer()
                        }
                        .padding(.bottom, 40)
                    }
                }
                .frame(height: 200)
                .clipShape(
                    RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                )
            }
            
            // Boutons header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.leading, 20)
                .padding(.top, 16)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
        }
    }
    
    // MARK: - Photo du provider
    
    private var providerPhotoSection: some View {
        VStack(spacing: 12) {
            // Photo du provider en cercle
            // Utiliser providerBannerUrl ou un placeholder
            AsyncImage(url: URL(string: booking.providerBannerUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty, .failure:
                    // Placeholder avec initiales
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text((booking.providerName?.first).map { String($0).uppercased() } ?? "?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.orange)
                    }
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .padding(.top, -50) // Overlap avec l'illustration
    }
    
    // MARK: - Question
    
    private var questionSection: some View {
        VStack(spacing: 8) {
            Text("Comment était le service de \(booking.providerName ?? "—") ?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("Donnez une note selon le service.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Étoiles dans boîte blanche
    
    private var ratingBoxSection: some View {
        VStack(spacing: 16) {
            // Étoiles
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        selectedRating = rating
                    } label: {
                        Image(systemName: selectedRating >= rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundColor(selectedRating >= rating ? .black : .gray.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Label selon la note
            if selectedRating > 0 {
                Text(ratingLabel(for: selectedRating))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func ratingLabel(for rating: Int) -> String {
        switch rating {
        case 1: return "Très mauvais"
        case 2: return "Mauvais"
        case 3: return "Moyen"
        case 4: return "Bien"
        case 5: return "Excellent !"
        default: return ""
        }
    }
    
    // MARK: - Catégories de service
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aspects du service")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(serviceCategories, id: \.0) { category in
                        CategoryButton(
                            title: category.2,
                            icon: category.1,
                            isSelected: selectedCategories.contains(category.0)
                        ) {
                            if selectedCategories.contains(category.0) {
                                selectedCategories.remove(category.0)
                            } else {
                                selectedCategories.insert(category.0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            Task {
                let success = await viewModel.createReview(
                    rating: selectedRating,
                    comment: nil // Pas de commentaire pour l'instant
                )
                if success {
                    showSuccessAlert = true
                }
            }
        } label: {
            Text("Envoyer l'avis")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedRating >= 1 ? Color.black : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(selectedRating < 1 || viewModel.isLoading)
        .padding(.top, 8)
    }
}

// MARK: - Category Button

private struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icône
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .gray)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Titre
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.black : Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
