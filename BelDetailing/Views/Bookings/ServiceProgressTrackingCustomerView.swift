//
//  ServiceProgressTrackingCustomerView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct ServiceProgressTrackingCustomerView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: ServiceProgressTrackingCustomerViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: ServiceProgressTrackingCustomerViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Progress Header
                        progressHeader
                        
                        // Steps Timeline
                        stepsTimeline
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.06).ignoresSafeArea()
                    ProgressView()
                }
            }
            .navigationTitle(R.string.localizable.serviceProgressTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(R.string.localizable.commonClose()) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tabBarVisibility.isHidden = true
                Task {
                    await viewModel.startPolling()
                }
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
                viewModel.stopPolling()
            }
        }
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Percentage
            Text("\(viewModel.progressPercentage)%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
            
            // Progress Bar
            ProgressView(value: Double(viewModel.progressPercentage), total: 100)
                .tint(.black)
                .scaleEffect(x: 1, y: 3, anchor: .center)
            
            // Current Step
            if let currentStep = viewModel.currentStep {
                VStack(spacing: 8) {
                    Text(R.string.localizable.serviceProgressCurrentStep())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(currentStep.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Steps Timeline
    private var stepsTimeline: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.serviceProgressSteps())
                .font(.system(size: 20, weight: .bold))
            
            ForEach(viewModel.steps) { step in
                StepRowCustomer(
                    step: step,
                    isCurrent: step.id == viewModel.currentStep?.id
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Step Row Customer (Read-only)
private struct StepRowCustomer: View {
    let step: ServiceStep
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(step.isCompleted ? Color.green : (isCurrent ? Color.blue : Color.gray.opacity(0.3)))
                    .frame(width: 44, height: 44)
                
                if step.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                } else if isCurrent {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("\(step.order)")
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            // Step Info
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Text("\(step.percentage)%")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if step.isCompleted {
                        Text(R.string.localizable.serviceProgressCompleted())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    } else if isCurrent {
                        Text(R.string.localizable.serviceProgressInProgress())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

