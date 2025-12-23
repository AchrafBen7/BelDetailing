//
//  LoadingOverlayView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/12/2025.
//

import SwiftUI

struct LoadingOverlayView: View {
    @EnvironmentObject var loadingManager: LoadingOverlayManager

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.4

    var body: some View {
        if loadingManager.isLoading {
            ZStack {
                // Fond blur sombre style Uber
                VisualEffectBlur(style: .systemUltraThinMaterialDark)
                    .ignoresSafeArea()

                // Carte centrale optionnelle (pour un look plus soigné)
                VStack {
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.8)
                                        .repeatForever()
                                        .delay(Double(index) * 0.15),
                                    value: scale
                                )
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                )
                .onAppear {
                    scale = 1.2
                    opacity = 1
                }
            }
            .transition(.opacity)
        }
    }
}
