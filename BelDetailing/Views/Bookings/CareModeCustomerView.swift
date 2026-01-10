//
//  CareModeCustomerView.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import SwiftUI
import RswiftResources
import Combine
/// Vue customer pour voir les photos intermédiaires (Care Mode)
struct CareModeCustomerView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: CareModeCustomerViewModel
    @State private var selectedPhoto: CareModeStepPhoto?
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CareModeCustomerViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                careModeHeader
                
                // Messages automatiques
                if !viewModel.autoMessages.isEmpty {
                    autoMessagesSection
                }
                
                // Photos par step
                if !viewModel.photosByStep.isEmpty {
                    photosByStepSection
                } else {
                    emptyStateView
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("NIOS Care Mode")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedPhoto) { photo in
            CareModePhotoFullScreenView(photo: photo)
        }
    }
    
    // MARK: - Header
    
    private var careModeHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.purple)
            
            Text("Suivi Premium")
                .font(.system(size: 24, weight: .bold))
            
            Text("Photos et messages en temps réel de votre service")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Auto Messages Section
    
    private var autoMessagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Messages")
                .font(.system(size: 20, weight: .bold))
            
            ForEach(viewModel.autoMessages) { message in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "message.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.message)
                            .font(.system(size: 15))
                        
                        Text(formatDate(message.sentAt))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Photos By Step Section
    
    private var photosByStepSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Photos par étape")
                .font(.system(size: 20, weight: .bold))
            
            ForEach(viewModel.photosByStep.keys.sorted(), id: \.self) { stepId in
                if let step = viewModel.steps.first(where: { $0.id == stepId }),
                   let photos = viewModel.photosByStep[stepId], !photos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(step.title)
                            .font(.system(size: 18, weight: .semibold))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(photos) { photo in
                                    AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        default:
                                            Color.gray.opacity(0.2)
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onTapGesture {
                                        selectedPhoto = photo
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text("Aucune photo pour l'instant")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Les photos apparaîtront ici au fur et à mesure de l'avancement du service.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }
}

// MARK: - ViewModel

@MainActor
final class CareModeCustomerViewModel: ObservableObject {
    @Published var photosByStep: [String: [CareModeStepPhoto]] = [:]
    @Published var autoMessages: [CareModeAutoMessage] = []
    @Published var isLoading = false
    
    let booking: Booking
    let engine: Engine
    
    var steps: [ServiceStep] {
        booking.progress?.steps ?? []
    }
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Charger les photos et messages depuis le backend
        // let photosResult = await engine.careModeService.getStepPhotos(bookingId: booking.id)
        // let messagesResult = await engine.careModeService.getAutoMessages(bookingId: booking.id)
        
        // Grouper les photos par step
        // photosByStep = Dictionary(grouping: photos, by: { $0.stepId })
    }
}

// MARK: - Photo Full Screen View

struct CareModePhotoFullScreenView: View {
    let photo: CareModeStepPhoto
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                AsyncImage(url: URL(string: photo.photoUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

