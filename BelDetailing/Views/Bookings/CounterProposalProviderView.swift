//
//  CounterProposalProviderView.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct CounterProposalProviderView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: CounterProposalProviderViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedTime = "10:00"
    @State private var message = ""
    
    private let availableTimes = [
        "08:00", "09:00", "10:00", "11:00",
        "12:00", "13:00", "14:00", "15:00",
        "16:00", "17:00", "18:00"
    ]
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CounterProposalProviderViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text(R.string.localizable.bookingCounterProposalTitle())
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    Text(R.string.localizable.bookingCounterProposalSubtitle())
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Date picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(R.string.localizable.bookingDate())
                            .font(.system(size: 16, weight: .semibold))
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Time picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(R.string.localizable.bookingTime())
                            .font(.system(size: 16, weight: .semibold))
                        
                        Menu {
                            ForEach(availableTimes, id: \.self) { time in
                                Button(time) {
                                    selectedTime = time
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedTime)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Message (optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(R.string.localizable.bookingCounterProposalMessage())
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField(
                            R.string.localizable.bookingCounterProposalMessagePlaceholder(),
                            text: $message,
                            axis: .vertical
                        )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .lineLimit(3...6)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(R.string.localizable.commonCancel()) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(R.string.localizable.commonSend()) {
                        Task {
                            let success = await viewModel.sendCounterProposal(
                                date: selectedDate.toISODateString(),
                                startTime: selectedTime,
                                endTime: selectedTime,
                                message: message.isEmpty ? nil : message
                            )
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Erreur", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            }
        }
    }
