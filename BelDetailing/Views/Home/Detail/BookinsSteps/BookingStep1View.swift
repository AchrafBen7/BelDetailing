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
                // === FIXED BACK BUTTON ===
                CustomBackButton {
                    dismiss()
                }
                // === MAIN SCROLLING CONTENT ===
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 20)
                        // MARK: - DATE PICKER
                        VStack(alignment: .leading, spacing: 20) {
                            Text(R.string.localizable.bookingSelectDate())
                                .font(.system(size: 22, weight: .bold))
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(.orange)
                            .padding(.top, -8)
                        }
                        .padding(24)
                        // MARK: - TIME PICKER
                        VStack(alignment: .leading, spacing: 20) {
                            Text(R.string.localizable.bookingSelectTime())
                                .font(.system(size: 22, weight: .bold))
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 4),
                                spacing: 16
                            ) {
                                ForEach(times, id: \.self) { time in
                                    Button {
                                        selectedTime = time
                                    } label: {
                                        Text(time)
                                            .font(.system(size: 17, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .foregroundColor(selectedTime == time ? .white : .black)
                                            .background(selectedTime == time ? .black : .white)
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(
                                                        Color.black.opacity(0.15),
                                                        lineWidth: selectedTime == time ? 0 : 1
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        // DETECT BOTTOM
                        Color.clear
                            .frame(height: 1)
                            .onAppear { hasReachedBottom = true }
                            .onDisappear { hasReachedBottom = false }
                        Spacer(minLength: 40)
                    }
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
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .cornerRadius(40)
                    }
                    .padding(.horizontal, 24)
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
