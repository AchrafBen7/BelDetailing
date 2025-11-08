//
//  OffersView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//
//
//  OffersView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import RswiftResources

struct OffersView: View {
  @StateObject private var vm: OffersViewModel
  @State private var showFilters = false

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: OffersViewModel(engine: engine))
  }

  var body: some View {
    NavigationStack {
      // ✅ VStack à la place de Group
      VStack {
        if vm.isLoading {
          LoadingView()
        } else if vm.offers.isEmpty {
          EmptyStateView(
            title: R.string.localizable.offersEmptyTitle(),
            message: R.string.localizable.offersEmptyMessage()
          )
        } else {
          ScrollView {
            LazyVStack(spacing: 14) {
              ForEach(vm.offers) { offer in
                OfferCard(offer: offer)
              }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle(R.string.localizable.tabOffers())
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showFilters.toggle()
          } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
              .symbolRenderingMode(.hierarchical)
          }
        }
      }
      .sheet(isPresented: $showFilters) {
        OfferFiltersSheet(
          selectedStatus: vm.selectedStatus,
          selectedType: vm.selectedType
        ) { status, type in
          Task { await vm.refreshFilters(status: status, type: type) }
        }
      }
      .alert(vm.errorText ?? "",
             isPresented: .constant(vm.errorText != nil)) {
        Button(R.string.localizable.commonOk(), role: .cancel) {
          vm.errorText = nil
        }
      }
    }
    .task { await vm.load() }
  }
}

#Preview {
  OffersView(engine: Engine(mock: true))
}
