//
//  BookingStatusBadge.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct BookingStatusBadge: View {
    let status: BookingStatus
    let paymentStatus: PaymentStatus?
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status.localizedTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor)
        .clipShape(Capsule())
        .shadow(color: statusColor.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return .blue
        case .started:
            return .blue
        case .inProgress:
            return .blue
        case .declined:
            return .red
        case .cancelled:
            return .gray
        case .completed:
            return .green
        }
    }
}

struct PaymentStatusBadge: View {
    let status: PaymentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            
            Text(statusText)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var icon: String {
        switch status {
        case .pending, .preauthorized:
            return "clock"
        case .processing:
            return "arrow.clockwise"
        case .paid:
            return "checkmark.circle.fill"
        case .refunded:
            return "arrow.uturn.left"
        case .failed:
            return "xmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch status {
        case .pending:
            return "En attente"
        case .preauthorized:
            return "Pré-autorisé"
        case .processing:
            return "En cours"
        case .paid:
            return "Payé"
        case .refunded:
            return "Remboursé"
        case .failed:
            return "Échoué"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending, .preauthorized:
            return .orange
        case .processing:
            return .blue
        case .paid:
            return .green
        case .refunded:
            return .blue
        case .failed:
            return .red
        }
    }
}

