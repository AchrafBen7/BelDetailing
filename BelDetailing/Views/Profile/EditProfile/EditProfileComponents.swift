//
//  EditProfileComponents.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

// MARK: - Section Card Component
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
    }
}

// MARK: - Editable Info Row Component
struct EditableInfoRow: View {
    let label: String
    @Binding var value: String
    var isEditable: Bool = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer(minLength: 12)
            if isEditable {
                TextField("", text: $value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
            } else {
                Text(value.isEmpty ? "—" : value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Metric Card Component
struct MetricCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

