//
//  ProgressIndicator.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

/// Indicateur de progression amélioré pour actions longues
struct ProgressIndicator: View {
    let progress: Double // 0.0 à 1.0
    let message: String?
    let showPercentage: Bool
    
    init(progress: Double, message: String? = nil, showPercentage: Bool = true) {
        self.progress = max(0.0, min(1.0, progress))
        self.message = message
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar avec animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            
            // Message et pourcentage
            HStack {
                if let message = message {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

/// Variante compacte pour les boutons
struct CompactProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: geometry.size.width * max(0.0, min(1.0, progress)), height: 4)
                    .animation(.linear(duration: 0.2), value: progress)
            }
        }
        .frame(height: 4)
    }
}

/// Indicateur de progression circulaire avec pourcentage
struct CircularProgressIndicator: View {
    let progress: Double // 0.0 à 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 6, showPercentage: Bool = true) {
        self.progress = max(0.0, min(1.0, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            
            // Percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressIndicator(progress: 0.65, message: "Uploading...", showPercentage: true)
            .padding()
        
        CompactProgressIndicator(progress: 0.45)
            .padding()
        
        CircularProgressIndicator(progress: 0.75, size: 80, showPercentage: true)
    }
    .padding()
}

