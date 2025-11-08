//
//  SearchView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

import SwiftUI
import Combine
import MapKit
import RswiftResources

struct SearchView: View {
  @StateObject private var vm: SearchViewModel
  @FocusState private var focus: Bool

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: SearchViewModel(engine: engine))
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 12) {
        searchBar
        filters

        if vm.isLoading {
          LoadingView()
        } else if vm.results.isEmpty {
          EmptyStateView(title: R.string.localizable.searchEmptyTitle(),
                         message: R.string.localizable.searchEmptyMessage())
        } else {
          ScrollView {
            VStack(spacing: 12) {
              ForEach(vm.results) { ProviderCard(provider: $0) }
            }
            .padding(.horizontal, 16)
          }
        }
      }
      .padding(.top, 8)
      .navigationTitle(R.string.localizable.tabSearch())
      .toolbar {
        ToolbarItem(placement: .keyboard) {
          Button(R.string.localizable.search(), action: { Task { await vm.search() }; focus = false })
        }
      }
    }
  }

  private var searchBar: some View {
    HStack {
      TextField(R.string.localizable.searchPlaceholder(), text: $vm.query)
        .textFieldStyle(.roundedBorder)
        .focused($focus)
      Button(R.string.localizable.search()) { Task { await vm.search() } }
        .buttonStyle(.borderedProminent)
    }
    .padding(.horizontal, 16)
  }

  private var filters: some View {
    HStack(spacing: 12) {
      Toggle(R.string.localizable.filterAtHome(), isOn: $vm.atHome)
        .toggleStyle(.switch)
      Spacer()
      // placeholder filtre de prix simple
      Menu {
        Button("€50")  { vm.maxPrice = 50  ; Task { await vm.search() } }
        Button("€100") { vm.maxPrice = 100 ; Task { await vm.search() } }
        Button("€150") { vm.maxPrice = 150 ; Task { await vm.search() } }
        Button(R.string.localizable.all()) { vm.maxPrice = nil ; Task { await vm.search() } }
      } label: {
        Label(vm.maxPrice == nil ? R.string.localizable.filterPrice() : "≤ €\(Int(vm.maxPrice!))",
              systemImage: "eurosign.circle")
      }
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  SearchView(engine: Engine(mock: true))
}
