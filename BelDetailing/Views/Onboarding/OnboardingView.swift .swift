//
//  OnboardingView.swift .swift
//  BelDetailing
//
//  Created by Achraf Benali on 09/11/2025.
//

import SwiftUI
import RswiftResources

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        VStack {
            // MARK: - Skip Button
            HStack {
                Spacer()
                Button(action: {
                    vm.skipOnboarding()
                }) {
                    R.string.localizable.commonSkip()
                        .textView(
                            style: AppStyle.TextStyle.description,
                            overrideColor: Color.secondary
                        )
                }
                .padding()
            }

            // MARK: - Pages
            TabView(selection: $vm.currentPage) {
                ForEach(Array(vm.pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                        .animation(.easeInOut, value: vm.currentPage)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // MARK: - Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<vm.totalPages, id: \.self) { index in
                    Capsule()
                        .fill(vm.currentPage == index ? .black : .gray.opacity(0.3))
                        .frame(width: vm.currentPage == index ? 30 : 8, height: 8)
                        .animation(.spring(), value: vm.currentPage)
                }
            }
            .padding(.vertical, 12)

            // MARK: - Action Button
            Button(action: {
                vm.nextPage()
            }) {
                Text(
                    vm.currentPage == vm.totalPages - 1
                    ? R.string.localizable.commonStart()
                    : R.string.localizable.commonNext()
                )
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
