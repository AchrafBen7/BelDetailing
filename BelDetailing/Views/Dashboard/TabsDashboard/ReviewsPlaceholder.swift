//  ProviderReviewsView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/11/2025.
//

import SwiftUI
import RswiftResources

struct ProviderReviewsView: View {

    @StateObject private var viewModel: ProviderReviewsViewModel

    init(engine: Engine, providerId: String) {
        _viewModel = StateObject(
            wrappedValue: ProviderReviewsViewModel(
                engine: engine,
                providerId: providerId
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // TITRE "Avis clients"
            Text(R.string.localizable.reviewsTitle())
                .font(.system(size: 26, weight: .bold))
                .padding(.horizontal, 20)

            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.reviews.isEmpty {
                emptyState
            } else {
                // Carte résumé
                ReviewsSummaryCardView(
                    averageRating: viewModel.averageRating,
                    totalReviews: viewModel.totalReviews,
                    distribution: viewModel.distribution
                )
                .padding(.horizontal, 20)

                // Liste des avis
                VStack(spacing: 16) {
                    ForEach(viewModel.reviews) { review in
                        ReviewCardView(review: review)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 10) {
            Text(R.string.localizable.reviewsEmptyTitle())
                .font(.system(size: 18, weight: .semibold))

            Text(R.string.localizable.reviewsEmptySubtitle())
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
    }
}
