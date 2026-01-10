//  ExtensionServiceCardStep2.swift
//  BelDetailing

import SwiftUI
import RswiftResources

extension BookingStep2View {
    
    var serviceDetailsCard: some View {
        let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
        let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
            basePrice: service.price,
            vehicleType: customerVehicleType
        )
        let adjustedDuration = engine.vehiclePricingService.calculateAdjustedDuration(
            baseDurationMinutes: service.durationMinutes,
            vehicleType: customerVehicleType
        )
        
        return HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            // Service info
            VStack(alignment: .leading, spacing: 6) {
                Text(service.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", detailer.rating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(adjustedDuration / 60)h")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Price
            Text("\(Int(adjustedPrice))€")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}
