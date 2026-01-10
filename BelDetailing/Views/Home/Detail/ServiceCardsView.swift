import SwiftUI
import RswiftResources

struct ServiceCardView: View {
    let service: Service
    let engine: Engine
    let onBook: () -> Void
    var isSelected: Bool = false
    var showCheckbox: Bool = false
    var onToggleSelection: (() -> Void)? = nil
    
    @State private var servicePhotos: [ServicePhoto] = []
    @State private var isLoadingPhotos = false
    @State private var selectedPhoto: ServicePhoto?
    @State private var currentPhotoIndex: Int = 0
    @State private var carouselTimer: Timer?
    
    init(service: Service, engine: Engine, onBook: @escaping () -> Void = {}, isSelected: Bool = false, showCheckbox: Bool = false, onToggleSelection: (() -> Void)? = nil) {
        self.service = service
        self.engine = engine
        self.onBook = onBook
        self.isSelected = isSelected
        self.showCheckbox = showCheckbox
        self.onToggleSelection = onToggleSelection
    }
    var body: some View {
        VStack(spacing: 0) {
            // --- IMAGE SERVICE ---
            ZStack(alignment: .topLeading) {
                // Afficher les photos du service si disponibles, sinon l'image principale
                if !servicePhotos.isEmpty {
                    servicePhotosCarousel
                } else {
                    AsyncImage(url: service.serviceImageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            Color.gray.opacity(0.15)
                        case .failure:
                            Image(systemName: "car.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.2))
                        @unknown default:
                            Color.gray.opacity(0.15)
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                // Checkmark en haut à gauche si mode sélection multiple
                if showCheckbox && isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(14)
                    .zIndex(100)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                }
                
                // PRICE BADGE en haut à droite
                VStack {
                    HStack {
                        Spacer()
                        Text("€\(Int(service.price))")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                            .padding(14)
                    }
                    Spacer()
                }
            }
            // --- CONTENT ---
            VStack(alignment: .leading, spacing: 16) {
                // TITLE + DURATION
                HStack {
                    Text(service.name)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(service.formattedDuration)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.gray)
                }
                
                // DESCRIPTION
                if let desc = service.description {
                    Text(desc)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // ✅ INCLUDED BUBBLE – DESIGN COMME MAQUETTE 2
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text(R.string.localizable.detailIncluded())
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    // 2 colonnes, bullets bien alignés
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading)
                        ],
                        alignment: .leading,
                        spacing: 8
                    ) {
                        includedRow(R.string.localizable.serviceIncludedWash())
                        includedRow(R.string.localizable.serviceIncludedDecontamination())
                        includedRow(R.string.localizable.serviceIncludedPolish2Steps())
                        includedRow(R.string.localizable.serviceIncludedWaxProtection())
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                
                // BUTTON (seulement si pas en mode sélection multiple)
                if !showCheckbox {
                    Button {
                        onBook()
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text(R.string.localizable.detailBookService())
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(isSelected && showCheckbox ? Color.black : Color.black.opacity(0.12), lineWidth: isSelected && showCheckbox ? 3 : 1.2)
        )
        .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
        .padding(.horizontal, 8)
        .onTapGesture {
            if showCheckbox {
                onToggleSelection?()
            }
        }
        .task {
            await loadServicePhotos()
        }
        .onChange(of: servicePhotos.count) { _ in
            if servicePhotos.count > 1 {
                startCarouselTimer()
            } else {
                stopCarouselTimer()
            }
        }
        .onDisappear {
            stopCarouselTimer()
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            ServicePhotoFullScreenView(photo: photo)
        }
    }
    
    // MARK: - Service Photos Carousel
    
    private var servicePhotosCarousel: some View {
        Group {
            if servicePhotos.count > 1 {
                // Carrousel automatique si plus d'une photo
                TabView(selection: $currentPhotoIndex) {
                    ForEach(Array(servicePhotos.enumerated()), id: \.element.id) { index, photo in
                        Button {
                            selectedPhoto = photo
                        } label: {
                            CachedAsyncImage(urlString: photo.thumbnailUrl ?? photo.imageUrl, useThumbnail: false) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .overlay(ProgressView())
                            }
                            .frame(height: 200)
                            .clipped()
                        }
                        .buttonStyle(.plain)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
                .onAppear {
                    startCarouselTimer()
                }
                .onDisappear {
                    stopCarouselTimer()
                }
            } else if let firstPhoto = servicePhotos.first {
                // Une seule photo : affichage simple
                Button {
                    selectedPhoto = firstPhoto
                } label: {
                    CachedAsyncImage(urlString: firstPhoto.thumbnailUrl ?? firstPhoto.imageUrl, useThumbnail: false) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                            .overlay(ProgressView())
                    }
                    .frame(height: 200)
                    .clipped()
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func startCarouselTimer() {
        stopCarouselTimer() // Arrêter le timer existant si présent
        
        guard servicePhotos.count > 1 else { return }
        
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard servicePhotos.count > 1 else { return }
            // Avancer l’index sur le MainActor
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPhotoIndex = (currentPhotoIndex + 1) % servicePhotos.count
            }
        }
        if let timer = carouselTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopCarouselTimer() {
        carouselTimer?.invalidate()
        carouselTimer = nil
    }
    
    // MARK: - Load Service Photos
    
    private func loadServicePhotos() async {
        isLoadingPhotos = true
        
        let result = await engine.servicePhotoService.getPhotos(serviceId: service.id)
        
        switch result {
        case .success(let photos):
            servicePhotos = photos
        case .failure:
            servicePhotos = []
        }
        
        isLoadingPhotos = false
    }
    
    // MARK: - PRIVATE HELPERS
    /// Une ligne "• Texte" bien propre, qui ne coupe pas bizarrement
    private func includedRow(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(.black)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Service Photo Full Screen View

private struct ServicePhotoFullScreenView: View {
    let photo: ServicePhoto
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                if let caption = photo.caption, !caption.isEmpty {
                    VStack(spacing: 8) {
                        Text(caption)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
    }
}

