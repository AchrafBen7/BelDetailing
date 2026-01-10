//
//  GoogleReviewPromptView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct GoogleReviewPromptView: View {
    let booking: Booking
    @EnvironmentObject var engine: Engine
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: GoogleReviewPromptViewModel
    @State private var selectedRating: Int = 0
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        _viewModel = StateObject(wrappedValue: GoogleReviewPromptViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Background avec overlay sombre
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Card du prompt
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await viewModel.dismissPrompt()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Contenu
                VStack(spacing: 24) {
                    // Icône
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                        .padding(.top, 8)
                    
                    // Titre
                    Text("Comment s'est passé le service ?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Sous-titre
                    Text("Votre avis aide ce detailer à se développer")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Étoiles
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { rating in
                            Button {
                                selectedRating = rating
                            } label: {
                                Image(systemName: selectedRating >= rating ? "star.fill" : "star")
                                    .font(.system(size: 40))
                                    .foregroundColor(selectedRating >= rating ? .yellow : .white.opacity(0.3))
                                    .animation(.spring(response: 0.3), value: selectedRating)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Message conditionnel
                    if selectedRating > 0 {
                        Text(selectedRating >= 4 
                             ? "Merci ! Voulez-vous laisser cet avis sur Google ?"
                             : "Merci pour votre retour")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }
                    
                    // Bouton d'action
                    if selectedRating > 0 {
                        Button {
                            Task {
                                await viewModel.sendRatingAndRedirect(rating: selectedRating)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                if selectedRating >= 4 {
                                    Image(systemName: "arrow.up.right.square")
                                }
                                Text(selectedRating >= 4 ? "Laisser un avis sur Google" : "Envoyer")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Bouton "Plus tard"
                    Button {
                        Task {
                            await viewModel.dismissPrompt()
                            dismiss()
                        }
                    } label: {
                        Text("Plus tard")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.95))
            )
            .padding(.horizontal, 24)
        }
        .task {
            await viewModel.loadOrCreatePrompt()
        }
    }
}
