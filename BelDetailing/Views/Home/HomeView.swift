//
//  HomeView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct HomeView: View {
  @StateObject private var vm: HomeViewModel
  init(engine: Engine) {
    _vm = StateObject(wrappedValue: HomeViewModel(engine: engine))
  }

  var body: some View {
    NavigationView {
      Group {
        if vm.isLoading {
          LoadingView()
        } else if vm.recommended.isEmpty {
          EmptyStateView(
            title: R.string.localizable.homeEmptyTitle(),
            message: R.string.localizable.homeEmptyMessage()
          )
        } else {
            ScrollView {
              VStack(alignment: .leading, spacing: 16) {

                // Titel (geen params)
                R.string.localizable.homeTitle()
                  .textView(style: AppStyle.TextStyle.title)

                // Subtitel (met 1 param: city)
                if let city = vm.cityName {
                  R.string.localizable.homeCitySubtitle(city)
                    .textView(style: AppStyle.TextStyle.description)
                }

                ForEach(vm.recommended) { provider in
                  ProviderCard(provider: provider)
                }
              }
              .padding(.horizontal, 16)
              .padding(.top, 12)
            }


        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    .task { await vm.load() }
    .alert(vm.errorText ?? "", isPresented: .constant(vm.errorText != nil)) {
      Button(R.string.localizable.commonOk(), role: .cancel) { vm.errorText = nil }
    }
  }
}

#Preview {
  HomeView(engine: Engine(mock: true))
}
