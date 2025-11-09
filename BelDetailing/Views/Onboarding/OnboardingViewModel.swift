//
//  OnboardingViewModel.swift
//  BelDetailing
//

import Foundation
import SwiftUI
import Combine
import RswiftResources

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var totalPages: Int { pages.count }

    struct OnboardingPageModel: Identifiable {
        let id = UUID()
        let image: String
        let title: StringResource
        let description: StringResource
        let accentColor: Color
    }

    let pages: [OnboardingPageModel] = [
        .init(
            image: "sparkles",
            title: R.string.localizable.onboardingFindProsTitle,
            description: R.string.localizable.onboardingFindProsDescription,
            accentColor: Color(R.color.secondaryOrange)
        ),
        .init(
            image: "calendar",
            title: R.string.localizable.onboardingBookFastTitle,
            description: R.string.localizable.onboardingBookFastDescription,
            accentColor: .gray
        ),
        .init(
            image: "shield",
            title: R.string.localizable.onboardingSecurePaymentTitle,
            description: R.string.localizable.onboardingSecurePaymentDescription,
            accentColor: Color(R.color.secondaryOrange)
        )
    ]
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            hasSeenOnboarding = true
        }
    }

    func skipOnboarding() {
        hasSeenOnboarding = true
    }
}
