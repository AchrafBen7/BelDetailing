//
//  recapSection.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

extension BookingStep3View {

    var recapSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // TITLE
            Text(R.string.localizable.bookingSummary())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    // === SERVICE IMAGE ===
                    AsyncImage(url: serviceImageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()

                        case .empty:
                            Color.gray.opacity(0.15)

                        case .failure:
                            Image(systemName: "car.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.4))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.15))

                        default:
                            Color.gray.opacity(0.15)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // === TEXT BLOCK ===
                    VStack(alignment: .leading, spacing: 8) {
                        Text(service.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        Text(detailer.companyName ?? detailer.displayName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)

                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            
                            Text("\(date.formatted(date: .abbreviated, time: .omitted)) · \(time)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    // PRICE (prix de base du service - le total est dans priceBreakdownSection)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(service.price))€")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                // Afficher la durée ajustée si différente
                let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
                let adjustedDuration = engine.vehiclePricingService.calculateAdjustedDuration(
                    baseDurationMinutes: service.durationMinutes,
                    vehicleType: customerVehicleType
                )
                
                if adjustedDuration != service.durationMinutes {
                    Divider()
                        .padding(.vertical, 8)
                    
                    HStack {
                        Text("Durée estimée")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(service.durationMinutes) min")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .strikethrough()
                            Text("\(adjustedDuration) min")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    /// SAFE image URL (évite tous les crashs + optionals)
    private var serviceImageURL: URL? {
        guard let urlString = service.imageUrl,
              !urlString.trimmingCharacters(in: .whitespaces).isEmpty,
              let url = URL(string: urlString)
        else {
            return nil
        }
        return url
    }
}
