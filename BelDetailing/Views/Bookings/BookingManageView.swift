//
//  BookingManageView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct BookingManageView: View {
    
    let booking: Booking
    let engine: Engine
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var newDate: Date
    @State private var newTime: String
    
    private let times = [
        "08:00","09:00","10:00","11:00",
        "12:00","14:00","15:00","16:00","17:00"
    ]
    
    // INIT
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        
        _newDate = State(initialValue:
            DateFormatters.isoDateTime(date: booking.date, time: booking.startTime) ?? Date()
        )
        _newTime = State(initialValue: booking.startTime)
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    Spacer().frame(height: 40)
                    
                    // MARK: - HEADER (comme sur la photo)
                    VStack(spacing: 6) {
                        Text(R.string.localizable.bookingManageUpdateTitle())
                            .font(.system(size: 26, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("\(booking.serviceName) – \(booking.providerName)")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - DATE SECTION
                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text(R.string.localizable.bookingManageDate())
                            .font(.system(size: 18, weight: .semibold))
                        
                        DatePicker(
                            "",
                            selection: $newDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.orange)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // MARK: - TIME SECTION
                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text(R.string.localizable.bookingManageTime())
                            .font(.system(size: 18, weight: .semibold))
                        
                        Menu {
                            ForEach(times, id: \.self) { time in
                                Button(time) { newTime = time }
                            }
                        } label: {
                            HStack {
                                Text(newTime)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - NEW DATE SUMMARY CARD
                    VStack(alignment: .leading, spacing: 6) {
                        Text(R.string.localizable.bookingManageNewDate())
                            .font(.system(size: 18, weight: .semibold))

                        Text("\(newDate.formatted(date: .long, time: .omitted)) à \(newTime)")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // MARK: - BUTTON "ENREGISTRER"
                    Button {
                        print("MODIFICATION CONFIRMED")
                        dismiss()
                    } label: {
                        Text(R.string.localizable.bookingManageSave())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MARK: - BUTTON "ANNULER" (ferme simplement la page)
                    Button {
                        dismiss()
                    } label: {
                        Text(R.string.localizable.commonBack())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 80)
                }
            }
            
            // MARK: - CLOSE BUTTON (croix)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(12)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
        }
        
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
}
