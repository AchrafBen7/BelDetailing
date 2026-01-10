//
//  DetailerDetailView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct DetailerDetailView: View {
    @StateObject private var vm: DetailerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var bookingService: Service?   // 👈 Step1 trigger (single service)
    @State private var selectedServices: Set<String> = []  // 👈 Multiple services selection
    @State private var showMultiBooking: Bool = false  // 👈 Trigger for multi-service booking
    @State private var selectedPortfolioPhoto: PortfolioPhoto?
    
    init(id: String, engine: Engine) {
        _vm = StateObject(wrappedValue: DetailerDetailViewModel(id: id, engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            ScrollView(showsIndicators: false) {
                
                if vm.isLoading {
                    
                    ProgressView()
                        .padding(.top, 80)
                    
                } else if let detailer = vm.detailer {
                    
                    VStack(spacing: 24) {
                        
                        DetailerDetailHeaderView(
                            detailer: detailer,
                            portfolioPhotos: vm.portfolioPhotos,
                            onPhotoTap: { photo in
                                selectedPortfolioPhoto = photo
                            }
                        )
                        
                        // Bio et autres infos sont maintenant dans le header
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text(R.string.localizable.detailContactInfo())
                                .font(.system(size: 22, weight: .semibold))
                                .padding(.horizontal, 20)
                            ContactInfoCard(
                                icon: "phone",
                                label: R.string.localizable.detailPhone(),
                                value: detailer.phone ?? "–"
                            )
                            .padding(.horizontal, 20)
                            ContactInfoCard(
                                icon: "envelope",
                                label: R.string.localizable.detailEmail(),
                                value: detailer.email ?? "–"
                            )
                            .padding(.horizontal, 20)
                            ContactInfoCard(
                                icon: "clock",
                                label: R.string.localizable.detailHours(),
                                value: detailer.openingHours ?? "–"
                            )
                            .padding(.horizontal, 20)
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            Text(R.string.localizable.detailServicesTitle())
                                .font(.system(size: 22, weight: .bold))
                                .padding(.horizontal, 20)
                            if vm.isLoadingServices {
                                ProgressView().padding(.top, 12)
                            } else if vm.services.isEmpty {
                                Text(R.string.localizable.detailNoServices())
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 20) {
                                    ForEach(vm.services) { service in
                                        ServiceCardView(
                                            service: service,
                                            engine: vm.engine,
                                            onBook: {
                                                // Mode single service (comportement original)
                                                bookingService = service
                                            },
                                            isSelected: selectedServices.contains(service.id),
                                            showCheckbox: true,
                                            onToggleSelection: {
                                                // Toggle sélection multiple
                                                if selectedServices.contains(service.id) {
                                                    selectedServices.remove(service.id)
                                                } else {
                                                    selectedServices.insert(service.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Bouton "Continuer" si des services sont sélectionnés
                                if !selectedServices.isEmpty {
                                    Button {
                                        showMultiBooking = true
                                    } label: {
                                        HStack {
                                            Text("Continuer")
                                                .font(.system(size: 17, weight: .semibold))
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.black)
                                        .cornerRadius(16)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.top, 6)
                        
                        if !vm.reviews.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                
                                HStack {
                                    Text(R.string.localizable.detailReviewsTitle())
                                        .font(.system(size: 24, weight: .bold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                    
                                    Text(String(format: "%.1f", vm.detailer?.rating ?? 0))
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text("(\(vm.detailer?.reviewCount ?? 0))")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                
                                ForEach(vm.reviews) { review in
                                    ReviewCardView(review: review)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            
            // Back button
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .padding(.top, 50)
            .padding(.leading, 20)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        
        .fullScreenCover(item: $bookingService) { service in
            NavigationStack {                          // 👈 on donne un nav context
                BookingStep1View(
                    service: service,
                    detailer: vm.detailer!,
                    engine: vm.engine
                )
                .environmentObject(tabBarVisibility)   // 👈 pour cacher la tabbar
            }
        }
        .fullScreenCover(isPresented: $showMultiBooking) {
            NavigationStack {
                if let detailer = vm.detailer {
                    MultiServiceBookingStep1View(
                        services: vm.services.filter { selectedServices.contains($0.id) },
                        detailer: detailer,
                        engine: vm.engine
                    )
                    .environmentObject(tabBarVisibility)
                }
            }
        }
        .fullScreenCover(item: $selectedPortfolioPhoto) { photo in
            PortfolioPhotoFullScreenView(photo: photo)
        }
        
    }
}

// MARK: - Portfolio Photo Full Screen View

private struct PortfolioPhotoFullScreenView: View {
    let photo: PortfolioPhoto
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

