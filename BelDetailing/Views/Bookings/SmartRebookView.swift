//
//  SmartRebookView.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import SwiftUI
import RswiftResources
import Combine
struct SmartRebookView: View {
    let suggestion: SmartRebookSuggestion
    let engine: Engine
    
    @StateObject private var viewModel: SmartRebookViewModel
    @Environment(\.dismiss) var dismiss
    
    init(suggestion: SmartRebookSuggestion, engine: Engine) {
        self.suggestion = suggestion
        self.engine = engine
        _viewModel = StateObject(wrappedValue: SmartRebookViewModel(suggestion: suggestion, engine: engine))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec illustration
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("Réservez à nouveau")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Votre service précédent s'est bien passé ? Réservez le même service dans 6 semaines !")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                    
                    // Card avec les détails
                    VStack(alignment: .leading, spacing: 16) {
                        // Provider
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text(suggestion.providerName)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Divider()
                        
                        // Services
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Services")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            ForEach(suggestion.serviceNames, id: \.self) { serviceName in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text(serviceName)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Date suggérée
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date suggérée")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text(formatDate(suggestion.suggestedDate))
                                    .font(.system(size: 15))
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("\(suggestion.suggestedStartTime) - \(suggestion.suggestedEndTime)")
                                    .font(.system(size: 15))
                            }
                        }
                        
                        Divider()
                        
                        // Prix
                        HStack {
                            Text("Prix total")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text("\(String(format: "%.2f", suggestion.totalPrice)) \(suggestion.currency.uppercased())")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Bouton 1-click
                    Button {
                        Task {
                            await viewModel.createRebook()
                            if viewModel.isSuccess {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                Text("Réserver maintenant")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 20)
                    
                    // Bouton "Plus tard"
                    Button {
                        dismiss()
                    } label: {
                        Text("Peut-être plus tard")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ré-booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .alert("Erreur", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }
}

// MARK: - ViewModel

@MainActor
final class SmartRebookViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    
    private let suggestion: SmartRebookSuggestion
    private let engine: Engine
    
    init(suggestion: SmartRebookSuggestion, engine: Engine) {
        self.suggestion = suggestion
        self.engine = engine
    }
    
    func createRebook() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Créer le booking avec les mêmes paramètres
        var bookingData: [String: Any] = [
            "provider_id": suggestion.providerId,
            "date": suggestion.suggestedDate,
            "start_time": suggestion.suggestedStartTime,
            "end_time": suggestion.suggestedEndTime,
            "address": suggestion.address
        ]
        
        // Si plusieurs services, utiliser service_ids, sinon service_id
        // Note: Si serviceIds est vide, le backend devra trouver les services correspondants
        if suggestion.serviceIds.count > 1 {
            bookingData["service_ids"] = suggestion.serviceIds
        } else if let firstServiceId = suggestion.serviceIds.first {
            bookingData["service_id"] = firstServiceId
        } else {
            // Fallback: utiliser le premier service du provider (le backend devra gérer cela)
            // Pour l'instant, on laisse le backend gérer avec provider_id uniquement
            // TODO: Récupérer les services du provider et utiliser le premier
        }
        
        let result = await engine.bookingService.createBooking(bookingData)
        
        switch result {
        case .success(let response):
            isSuccess = true
            // Notification de succès
            NotificationsManager.shared.notifyBookingConfirmed(
                bookingId: response.booking.id,
                providerName: suggestion.providerName,
                date: suggestion.suggestedDate
            )
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

