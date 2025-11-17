//
//  ProviderServiceCardView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 17/11/2025.
//
import SwiftUI
import RswiftResources

struct ProviderServiceCardView: View {

    let service: Service
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text(service.name)
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Circle()
                    .fill(service.isAvailable ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 10, height: 10)
            }

            if let desc = service.description {
                Text(desc)
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
            }

            HStack(spacing: 24) {

                VStack(alignment: .leading) {
                    Text("\(Int(service.price))€")
                        .font(.system(size: 22, weight: .bold))
                    Text(service.formattedDuration)
                        .foregroundColor(.gray)
                        .font(.caption)
                }

                Divider().frame(height: 32)

                VStack(alignment: .leading) {
                    Text("12") // futur: service.reservationCount
                        .font(.system(size: 22, weight: .bold))
                    Text(R.string.localizable.dashboardReservations())
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }

            HStack(spacing: 12) {

                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text(R.string.localizable.dashboardEdit())  // ✅ FIX
                            .textView(style: .buttonSecondary)      // optionnel si tu veux ton style
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.2))
                    )
                }


                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }

        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

