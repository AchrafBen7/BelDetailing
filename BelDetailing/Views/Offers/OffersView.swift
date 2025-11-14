//  OffersView.swift
//  BelDetailing

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
            VStack(alignment: .leading, spacing: 0) {
                header
                searchBar
                statusChips        // ⬅️ barre Toutes / Ouvertes / Récentes
                content
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
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

// MARK: - Subviews

private extension OffersView {

    // MARK: Header — titre + petite intro
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
          (  R.string.localizable.tabOffers() + ".")
                .textView(style: .heroTitle)

            Text(R.string.localizable.offersIntroDescription())
                .font(.system(size: 15))
                .foregroundColor(Color(R.color.secondaryText))
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)   // ⬅️ un peu plus d’espace sous la description
    }

    // MARK: Search Bar + Filter button
    var searchBar: some View {
        HStack(spacing: 12) {
            searchField
            filterButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)   // ⬅️ avant 10 → un peu plus d’air
    }
    var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundColor(Color(R.color.secondaryText))

            TextField(
                R.string.localizable.searchCityPlaceholder(),
                text: $vm.locationQuery
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onChange(of: vm.locationQuery) { _ in
                vm.filterByLocation()
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }

    var filterButton: some View {
        Button {
            showFilters.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18))
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: Chips: Toutes / Ouvertes / Récentes
    var statusChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                chip(
                    title: R.string.localizable.filterAll(),
                    isSelected: vm.selectedQuickFilter == .all
                ) {
                    vm.applyQuickFilter(.all)
                }

                chip(
                    title: R.string.localizable.filterOpen(),
                    isSelected: vm.selectedQuickFilter == .open
                ) {
                    vm.applyQuickFilter(.open)
                }

                chip(
                    title: R.string.localizable.filterRecent(),
                    isSelected: vm.selectedQuickFilter == .recent
                ) {
                    vm.applyQuickFilter(.recent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(isSelected ? Color.black : Color.white)
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.07), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: Content
    @ViewBuilder
    var content: some View {
        if vm.isLoading {
            LoadingView()
        } else if vm.offers.isEmpty {
            EmptyStateView(
                title: R.string.localizable.offersEmptyTitle(),
                message: R.string.localizable.offersEmptyMessage()
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(vm.offers) { offer in
                        OfferCard(offer: offer)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }
}
