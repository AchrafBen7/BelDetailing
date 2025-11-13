import SwiftUI
import MapKit
import RswiftResources

struct SearchView: View {
  @StateObject private var vm: SearchViewModel
  @FocusState private var isSearchFocused: Bool
  @State private var showFilters = false
  @State private var topRated = false
  @State private var debounceTask: Task<Void, Never>?

  @State private var region = MKCoordinateRegion(
    center: .init(latitude: 50.8503, longitude: 4.3517),
    span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25)
  )

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: SearchViewModel(engine: engine))
  }

  private var displayedResults: [Detailer] {
    topRated ? vm.results.sorted { $0.rating > $1.rating } : vm.results
  }

  var body: some View {
    ZStack(alignment: .top) {
      // === MAP ===
      Map(coordinateRegion: $region, annotationItems: displayedResults) { pos in
        MapAnnotation(coordinate: .init(latitude: pos.lat, longitude: pos.lng)) {
          Button {
            withAnimation(.easeInOut) {
              region.center = .init(latitude: pos.lat, longitude: pos.lng)
              region.span = .init(latitudeDelta: 0.07, longitudeDelta: 0.07)
            }
          } label: {
            Image(systemName: "mappin.circle.fill")
              .font(.system(size: 22, weight: .bold))
              .foregroundColor(.accentColor)
          }
        }
      }
      .ignoresSafeArea()

      // === HEADER (search + filter + chips) ===
      VStack(alignment: .leading, spacing: 12) {

        // --- BARRE DE RECHERCHE + BOUTON FILTRE ---
        HStack(spacing: 12) {
          HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 17, weight: .regular))
              .foregroundColor(Color(R.color.secondaryText))

            TextField(R.string.localizable.searchPlaceholder(), text: $vm.query)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              .focused($isSearchFocused)
              .onSubmit { Task { await vm.search() } }
              .onChange(of: vm.query) { _ in
                debounceTask?.cancel()
                debounceTask = Task { @MainActor in
                  try? await Task.sleep(nanoseconds: 350_000_000)
                  await vm.search()
                }
              }
          }
          .padding(.horizontal, 14)
          .frame(height: 48)
          .background(Color.white.opacity(0.9))
          .clipShape(Capsule())
          .overlay(
            Capsule().stroke(Color.black.opacity(0.22), lineWidth: 1) // 👈 plus clair
          )
          .shadow(color: .black.opacity(0.08), radius: 2, y: 1) // 👈 ombre douce et discrète

          Button { showFilters = true } label: {
            Image(systemName: "slider.horizontal.3")
              .font(.system(size: 18, weight: .regular))
              .foregroundColor(.black)
              .frame(width: 48, height: 48)
              .background(Color.white.opacity(0.9))
              .clipShape(Circle())
              .overlay(
                Circle().stroke(Color.black.opacity(0.22), lineWidth: 1) // 👈 même ton clair
              )
              .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
          }
          .buttonStyle(.plain)
          .accessibilityLabel(R.string.localizable.filterTitle())
        }
        .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        .padding(.top, 10)

        // --- CHIPS ---
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            Chip(title: R.string.localizable.chipOffers()) { showFilters = true }
            Chip(title: R.string.localizable.chipPrice()) { showFilters = true }
            Chip(title: R.string.localizable.filterAtHome(), isOn: vm.atHome) {
              vm.atHome.toggle()
              Task { await vm.search() }
            }
            Chip(title: R.string.localizable.chipTopRated(), isOn: topRated) {
              topRated.toggle()
            }
          }
          .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        }
      }
      .padding(.top, 8)

      // === HORIZONTAL CARDS ===
      VStack {
        Spacer()

        if vm.isLoading {
          LoadingView()
            .padding(.bottom, 140)
        } else if displayedResults.isEmpty {
            EmptyStateView(
              title: R.string.localizable.searchEmptyTitle(),
              message: R.string.localizable.searchEmptyMessage(),
              onRetry: { Task { await vm.search() } },
              onClear: {
                vm.resetFilters()
                // Si tu as un toggle “mieux notés” côté vue :
                topRated = false
                Task { await vm.search() }
              }
            )
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            .padding(.bottom, 140)

        } else {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
              ForEach(displayedResults) { provider in
                ProviderSearchHorizontal(provider: provider)
                  .onTapGesture {
                    withAnimation(.easeInOut) {
                      region.center = .init(latitude: provider.lat, longitude: provider.lng)
                      region.span = .init(latitudeDelta: 0.07, longitudeDelta: 0.07)
                    }
                  }
              }
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
          }
          .padding(.bottom, 130)
        }
      }
      .ignoresSafeArea(edges: .bottom)
    }
    .task {
      if vm.results.isEmpty { await vm.search() }
      if vm.cities.isEmpty { await vm.loadCities() }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar(.hidden, for: .navigationBar)
    .sheet(isPresented: $showFilters) {
      FilterSheetView(
        maxPrice: $vm.maxPrice,
        selectedCity: $vm.city,
        atHome: $vm.atHome,
        cities: vm.cities
      ) {
        showFilters = false
        Task { await vm.search() }
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
  }
}

// MARK: - CHIP COMPONENT
private struct Chip: View {
  let title: String
  var isOn: Bool = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 15, weight: .regular))
        .foregroundColor(.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
        .overlay(
          Capsule().stroke(Color.black.opacity(0.22), lineWidth: 1) // 👈 bordure un peu plus claire
        )
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        .overlay {
          if isOn {
            Capsule()
              .fill(Color.black.opacity(0.08))
          }
        }
    }
    .buttonStyle(.plain)
  }
}
