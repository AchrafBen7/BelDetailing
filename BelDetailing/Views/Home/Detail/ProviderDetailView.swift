//
//  DetailerDetailView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//

import SwiftUI
import RswiftResources

struct DetailerDetailView: View {
    
    @StateObject private var vm: DetailerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(id: String, engine: Engine) {
        _vm = StateObject(wrappedValue: DetailerDetailViewModel(id: id, engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // 🔥 SCROLL CONTENT
            ScrollView(showsIndicators: false) {
                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 80)
                    
                } else if let detailer = vm.detailer {
                    
                    VStack(spacing: 24) {
                        
                        // --- HEADER ---
                        DetailerDetailHeaderView(detailer: detailer)
                        
                        // --- BIO ---
                        if let bio = detailer.bio {
                            Text(bio)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }
                        
                        // --- BUTTONS (Appeler / Message) ---
                        HStack(spacing: 16) {
                            DetailerActionButton(
                                icon: "phone",
                                title: R.string.localizable.detailCall()
                            ) {
                                // TODO
                            }
                            
                            DetailerActionButton(
                                icon: "envelope",
                                title: R.string.localizable.detailMessage()
                            ) {
                                // TODO
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // --- CONTACT INFO ---
                        VStack(alignment: .leading, spacing: 16) {
                            Text(R.string.localizable.detailContactInfo())
                                .font(.system(size: 22, weight: .semibold))
                                .padding(.horizontal, 20)
                            
                            ContactInfoCard(
                                icon: "phone",
                                label: R.string.localizable.detailPhone(),
                                value: "+32 123 456 789"
                            )
                            .padding(.horizontal, 20)
                            
                            ContactInfoCard(
                                icon: "envelope",
                                label: R.string.localizable.detailEmail(),
                                value: "contact@detailpro.be"
                            )
                            .padding(.horizontal, 20)
                            
                            ContactInfoCard(
                                icon: "clock",
                                label: R.string.localizable.detailHours(),
                                value: "Lun–Sam: 9h–18h"
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // --- SERVICES PROPOSÉS ---
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text(R.string.localizable.detailServicesTitle())
                                .font(.system(size: 22, weight: .bold))
                                .padding(.horizontal, 20)
                            
                            if vm.isLoadingServices {
                                ProgressView()
                                    .padding(.top, 12)
                            } else if vm.services.isEmpty {
                                Text(R.string.localizable.detailNoServices())
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 20) {
                                    ForEach(vm.services) { service in
                                        ServiceCardView(service: service)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 6)
                        // --- REVIEWS SECTION ---
                        if !vm.reviews.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                
                                // Titre + score
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
                                
                                // Liste des reviews
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
            
            // 🔙 BACK BUTTON (white arrow)
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .padding(.top, 50)       // ⬅️ ajusté pour ne pas coller au notch
            .padding(.leading, 20)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
    }
}
