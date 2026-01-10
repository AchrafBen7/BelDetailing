//
//  ServiceProgressTrackingProviderView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct ServiceProgressTrackingProviderView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: ServiceProgressTrackingProviderViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var showCompleteConfirmation = false
    @State private var showNoShowProtection = false
    @State private var isCareModeEnabled = false // TODO: Récupérer depuis le booking
    @State private var expandedStepId: String? // Pour afficher les photos d'un step
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: ServiceProgressTrackingProviderViewModel(booking: booking, engine: engine))
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
                        
                        // Steps List
                        stepsList
                        
                        // No-Show Protection Button (si service confirmé mais pas encore commencé)
                        if booking.status == .confirmed {
                            noShowProtectionButton
                        }
                        
                        // Complete Button (if all steps done)
                        if viewModel.isAllStepsCompleted {
                            completeButton
                        }
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
            .alert(R.string.localizable.serviceProgressCompleteConfirmTitle(), isPresented: $showCompleteConfirmation) {
                Button(R.string.localizable.commonCancel(), role: .cancel) {}
                Button(R.string.localizable.serviceProgressCompleteConfirmButton()) {
                    Task {
                        await viewModel.completeService()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text(R.string.localizable.serviceProgressCompleteConfirmMessage())
            }
            .alert(R.string.localizable.errorTitle(), isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button(R.string.localizable.commonOk()) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                tabBarVisibility.isHidden = true
                Task {
                    await viewModel.load()
                }
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
            }
            .fullScreenCover(isPresented: $showNoShowProtection) {
                NoShowProtectionView(booking: booking, engine: engine)
            }
        }
    }
    
    // MARK: - No-Show Protection Button
    
    private var noShowProtectionButton: some View {
        Button {
            showNoShowProtection = true
        } label: {
            HStack {
                Image(systemName: "location.circle.fill")
                Text("Client absent ?")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 14))
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
                Text(currentStep.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Steps List
    private var stepsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.serviceProgressSteps())
                .font(.system(size: 20, weight: .bold))
            
            ForEach(viewModel.steps) { step in
                VStack(spacing: 12) {
                    StepRowProvider(
                        step: step,
                        isCurrent: step.id == viewModel.currentStep?.id,
                        onComplete: {
                            Task {
                                await viewModel.completeStep(stepId: step.id)
                            }
                        }
                    )
                    
                    // Care Mode: Photos du step (si activé et step complété ou en cours)
                    if isCareModeEnabled && (step.isCompleted || step.id == viewModel.currentStep?.id) {
                        CareModeStepPhotoView(
                            step: step,
                            bookingId: booking.id,
                            engine: engine
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Care Mode Toggle
    private var careModeToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("NIOS Care Mode")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Toggle("", isOn: $isCareModeEnabled)
                    .labelsHidden()
            }
            
            Text("Photos intermédiaires et messages automatiques pour une transparence maximale")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Complete Button
    private var completeButton: some View {
        Button {
            showCompleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(R.string.localizable.serviceProgressComplete())
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Step Row Provider
private struct StepRowProvider: View {
    let step: ServiceStep
    let isCurrent: Bool
    let onComplete: () -> Void
    
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
                    Image(systemName: "play.fill")
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
                
                Text("\(step.percentage)%")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Complete Button
            if !step.isCompleted && isCurrent {
                Button {
                    onComplete()
                } label: {
                    Text(R.string.localizable.serviceProgressMarkComplete())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
    }
}

