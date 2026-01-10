//
//  ProgressIndicatorView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

/// Indicateur de progression avec animation
struct ProgressIndicatorView: View {
    let progress: Double // 0.0 ... 1.0
    let message: String?
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Cercle de fond
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // Cercle de progression
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.black, Color.gray],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: animatedProgress)
                
                // Pourcentage
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            if let message = message {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            animatedProgress = newValue
        }
    }
}

/// Indicateur de progression linéaire
struct LinearProgressView: View {
    let progress: Double // 0.0 ... 1.0
    let height: CGFloat
    let backgroundColor: Color
    let progressColor: Color
    
    init(
        progress: Double,
        height: CGFloat = 4,
        backgroundColor: Color = Color.gray.opacity(0.2),
        progressColor: Color = .black
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.progressColor = progressColor
    }
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fond
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                // Barre de progression
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * animatedProgress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            animatedProgress = newValue
        }
    }
}

