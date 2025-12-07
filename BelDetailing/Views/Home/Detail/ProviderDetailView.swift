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
    @State private var bookingService: Service?   // 👈 Step1 trigger
    
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
                        
                        DetailerDetailHeaderView(detailer: detailer)
                        
                        if let bio = detailer.bio {
                            Text(bio)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }
                        
                        HStack(spacing: 16) {
                            DetailerActionButton(
                                icon: "phone",
                                title: R.string.localizable.detailCall()
                            ) {}
                            
                            DetailerActionButton(
                                icon: "envelope",
                                title: R.string.localizable.detailMessage()
                            ) {}
                        }
                        .padding(.horizontal, 20)
                        
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
                                        ServiceCardView(service: service) {
                                            bookingService = service       // 👈 NEW
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
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
        
    }
}

