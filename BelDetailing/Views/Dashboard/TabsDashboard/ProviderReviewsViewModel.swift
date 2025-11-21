//
//  ProviderReviewsViewModel.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//



import Foundation
import Combine

@MainActor
final class ProviderReviewsViewModel: ObservableObject {

    @Published var reviews: [Review] = []
    @Published var isLoading: Bool = false
    @Published var errorText: String?

    let engine: Engine
    let providerId: String

    init(engine: Engine, providerId: String) {
        self.engine = engine
        self.providerId = providerId
    }

    // MARK: - Loading
    func load() async {
        isLoading = true
        defer { isLoading = false }

        let response = await engine.reviewService.getReviews(providerId: providerId)

        switch response {
        case .success(let items):
            reviews = items
            errorText = nil
        case .failure(let error):
            reviews = []
            errorText = error.localizedDescription
        }
    }

    // MARK: - Stats
    var totalReviews: Int {
        reviews.count
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }

    /// Distribution par nombre d'étoiles 1...5
    var distribution: [Int: Int] {
        var dict: [Int: Int] = [:]
        for dis in 1...5 { dict[dis] = 0 }
        for review in reviews {
            dict[review.rating, default: 0] += 1
        }
        return dict
    }
}
