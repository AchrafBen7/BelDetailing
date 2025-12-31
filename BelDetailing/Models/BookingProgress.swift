//
//  BookingProgress.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import Foundation

// MARK: - Service Step

struct ServiceStep: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let percentage: Int  // 0-100, sum of all steps = 100
    var isCompleted: Bool
    let order: Int  // Order of the step in the sequence
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case percentage
        case isCompleted = "is_completed"
        case order
    }
}

// MARK: - Booking Progress

struct BookingProgress: Codable, Hashable, Equatable {
    let bookingId: String
    let steps: [ServiceStep]
    let currentStepIndex: Int?  // Index of the current active step
    let totalProgress: Int  // 0-100, calculated from completed steps
    
    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case steps
        case currentStepIndex = "current_step_index"
        case totalProgress = "total_progress"
    }
    
    init(bookingId: String, steps: [ServiceStep], currentStepIndex: Int? = nil, totalProgress: Int? = nil) {
        self.bookingId = bookingId
        self.steps = steps.sorted(by: { $0.order < $1.order })
        
        // Calculate current step index (first incomplete step)
        if let calculatedIndex = steps.firstIndex(where: { !$0.isCompleted }) {
            self.currentStepIndex = calculatedIndex
        } else if steps.allSatisfy({ $0.isCompleted }) {
            self.currentStepIndex = steps.count - 1  // All completed, last step
        } else {
            self.currentStepIndex = 0  // Start from first step
        }
        
        // Calculate total progress from completed steps
        if let calculatedProgress = totalProgress {
            self.totalProgress = calculatedProgress
        } else {
            let completedPercentage = steps.filter { $0.isCompleted }.reduce(0) { $0 + $1.percentage }
            self.totalProgress = completedPercentage
        }
    }
}

// MARK: - Default Service Steps

extension ServiceStep {
    /// Default steps for a car detailing service
    static func defaultSteps() -> [ServiceStep] {
        [
            ServiceStep(id: "step_1", title: "Préparation", percentage: 10, isCompleted: false, order: 1),
            ServiceStep(id: "step_2", title: "Nettoyage extérieur", percentage: 25, isCompleted: false, order: 2),
            ServiceStep(id: "step_3", title: "Nettoyage intérieur", percentage: 30, isCompleted: false, order: 3),
            ServiceStep(id: "step_4", title: "Finition", percentage: 25, isCompleted: false, order: 4),
            ServiceStep(id: "step_5", title: "Vérification finale", percentage: 10, isCompleted: false, order: 5)
        ]
    }
}

// MARK: - Extensions

extension BookingProgress {
    var currentStep: ServiceStep? {
        guard let index = currentStepIndex, index < steps.count else { return nil }
        return steps[index]
    }
    
    var nextStep: ServiceStep? {
        guard let index = currentStepIndex, index + 1 < steps.count else { return nil }
        return steps[index + 1]
    }
    
    var isAllStepsCompleted: Bool {
        steps.allSatisfy { $0.isCompleted }
    }
    
    func step(at index: Int) -> ServiceStep? {
        guard index >= 0 && index < steps.count else { return nil }
        return steps[index]
    }
}

