//
//  BookingStep1View.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct BookingStep1View: View {
    // MARK: - REQUIRED PARAMETERS
    let service: Service
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
                        
                        // === SERVICE DETAILS CARD ===
                        serviceDetailsCard
                        
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
    
    // MARK: - Service Details Card
    private var serviceDetailsCard: some View {
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
        .background(Color.white)
        .cornerRadius(20)
    }
    
    // MARK: - Date Selection Card
    private var dateSelectionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                // Icon
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
                // Icon
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
        BookingStep2View(
            service: service,
            detailer: detailer,
            date: selectedDate,
            time: selectedTime ?? "",
            engine: engine
        )
        .environmentObject(tabBarVisibility)
    }
}
