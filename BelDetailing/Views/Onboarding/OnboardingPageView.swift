//
//  OnboardingPageView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 09/11/2025.
//

import SwiftUI
import RswiftResources

struct OnboardingPageView: View {
    let page: OnboardingViewModel.OnboardingPageModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(40)
                .background(page.accentColor.opacity(0.1))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .foregroundColor(page.accentColor)

            // Titre
            (page.title())
              .textView(
                style: AppStyle.TextStyle.sectionTitle,
                multilineAlignment: .center
              )
              .multilineTextAlignment(.center)
              .padding(.horizontal, 24)

            // Description
            (page.description())
              .textView(
                style: AppStyle.TextStyle.description,
                overrideColor: Color.secondary,
                multilineAlignment: .center
              )
              .multilineTextAlignment(.center)
              .padding(.horizontal, 24)


            Spacer()
        }
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingViewModel().pages.first!
    )
}

