//
//  MultiServiceBookingStep1View.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct MultiServiceBookingStep1View: View {
    // MARK: - REQUIRED PARAMETERS
    let services: [Service]
    let detailer: Detailer
    let engine: Engine
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: String?
    @State private var hasReachedBottom = false
    @State private var goToStep2: Bool = false
    private let times = [
        "09:00","10:00","11:00","12:00",
        "14:00","15:00","16:00","17:00"
    ]
    
    // Calcul du prix total
    private var totalPrice: Double {
        let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
        return services.reduce(0) { total, service in
            let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                basePrice: service.price,
                vehicleType: customerVehicleType
            )
            return total + adjustedPrice
        }
    }
    
    // Calcul de la durée totale
    private var totalDuration: Int {
        let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
        return services.reduce(0) { total, service in
            let adjustedDuration = engine.vehiclePricingService.calculateAdjustedDuration(
                baseDurationMinutes: service.durationMinutes,
                vehicleType: customerVehicleType
            )
            return total + adjustedDuration
        }
    }
    
    var body: some View {
        ZStack {
            // === BACKGROUND ===
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // === HEADER ===
                headerSection
                
                // === MAIN SCROLLING CONTENT ===
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)
                        
                        // === SERVICES SUMMARY CARD ===
                        servicesSummaryCard
                        
                        // === TOTAL PRICE CARD ===
                        totalPriceCard
                        
                        // === DATE SELECTION CARD ===
                        dateSelectionCard
                        
                        // === TIME SELECTION CARD ===
                        timeSelectionCard
                        
                        // DETECT BOTTOM
                        Color.clear
                            .frame(height: 1)
                            .onAppear { hasReachedBottom = true }
                            .onDisappear { hasReachedBottom = false }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // === FIXED CONTINUE BUTTON ===
            VStack {
                Spacer()
                if hasReachedBottom && selectedTime != nil {
                    Button {
                        goToStep2 = true
                    } label: {
                        Text(R.string.localizable.bookingContinue())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            
            // === NAVIGATION LINK ===
            NavigationLink(
                destination: destinationStep2,
                isActive: $goToStep2
            ) { EmptyView() }
        }
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
            
            // Step indicator
            VStack(spacing: 8) {
                Text("Étape 1/3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                HStack(spacing: 6) {
                    // Step 1 - active
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black)
                        .frame(width: 24, height: 4)
                    
                    // Step 2 - inactive
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 4)
                    
                    // Step 3 - inactive
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 4)
                }
            }
            
            Spacer()
            
            // Spacer pour équilibrer
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Services Summary Card
    private var servicesSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "list.bullet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Services sélectionnés")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                ForEach(services) { service in
                    let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
                    let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                        basePrice: service.price,
                        vehicleType: customerVehicleType
                    )
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("\(service.durationMinutes) min")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(adjustedPrice))€")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                    
                    if service.id != services.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    // MARK: - Total Price Card
    private var totalPriceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Text("\(Int(totalPrice))€")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Durée totale: \(totalDuration / 60)h\(totalDuration % 60 > 0 ? " \(totalDuration % 60)min" : "")")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Date Selection Card
    private var dateSelectionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(R.string.localizable.bookingSelectDate())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.orange)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    // MARK: - Time Selection Card
    private var timeSelectionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(R.string.localizable.bookingSelectTime())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 12
            ) {
                ForEach(times, id: \.self) { time in
                    Button {
                        selectedTime = time
                    } label: {
                        Text(time)
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(selectedTime == time ? .white : .black)
                            .background(selectedTime == time ? Color.black : Color.gray.opacity(0.15))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    // MARK: - DESTINATION STEP 2
    private var destinationStep2: some View {
        MultiServiceBookingStep2View(
            services: services,
            detailer: detailer,
            date: selectedDate,
            time: selectedTime ?? "",
            engine: engine
        )
        .environmentObject(tabBarVisibility)
    }
}

