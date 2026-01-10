//
//  HomeHeroSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 12/11/2025.
//

import SwiftUI
import RswiftResources

struct HomeHeroSection: View {
    let cityName: String
    let heroImageName: String
    let title: String
    let subtitle: String
    var onLocationTap: () -> Void = {}
    var onProfileTap: () -> Void = {}
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // === BACKGROUND ===
                Image(heroImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: 420)
                    .clipped()
                // Dégradé sombre + dégradé blanc bas
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.25), .black.opacity(0.65)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.9)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(height: AppStyle.Padding.big32.rawValue * 3.5)
                    }
                
                VStack {
                    // === TOP BAR ===--
                    HStack {
                      // Location pill (regular, perfectly centered)
                      Button(action: onLocationTap) {
                        HStack(spacing: 8) {
                          Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 16, weight: .regular))
                            .imageScale(.medium)
                            .offset(y: 0.5)                // tiny optical fix so it feels level
                          Text(cityName)
                            .font(.system(size: 17, weight: .regular))  // <- regular (not bold)
                        }
                        .foregroundColor(.black)
                        .frame(height: 34)                 // consistent vertical centering
                        .padding(.horizontal, 14)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                          Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                      }

                      Spacer()

                      Button(action: onProfileTap) {
                        Image(systemName: "person.fill")
                          .font(.system(size: 18, weight: .medium))
                          .foregroundColor(.white)
                          .padding(12)
                          .background(Color.black.opacity(0.7))
                          .clipShape(Circle())
                      }
                    }
                    .padding(.horizontal, AppStyle.Padding.small16.rawValue)
                    .padding(.top, geo.safeAreaInsets.top + AppStyle.Padding.big32.rawValue * 2)

                    Spacer()
                    // === TITLES ===
                    VStack(alignment: .leading, spacing: AppStyle.Padding.small16.rawValue) {
                        Text(title)
                            .font(AppStyle.TextStyle.title.font)       // ⬅️ plus grand (37)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .shadow(radius: 2)
                            .lineSpacing(4)
                        Text(subtitle)
                            .font(AppStyle.TextStyle.description.font) // 20
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppStyle.Padding.small16.rawValue)
                    .padding(.bottom, AppStyle.Padding.medium24.rawValue + 40) // Remonté de 40px
                    
                }
                .frame(width: geo.size.width, height: 420)
            }
            .frame(height: 420 + geo.safeAreaInsets.top)
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 420)
    }
}

