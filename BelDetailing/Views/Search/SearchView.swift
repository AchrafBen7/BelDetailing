//
//  SearchView.swift
//  BelDetailing
//

import SwiftUI
import MapKit
import RswiftResources

struct SearchView: View {
  @StateObject private var vm: SearchViewModel
  @FocusState private var isSearchFocused: Bool
  @State private var showFilters = false

  // Région défaut: Bruxelles
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517),
    span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
  )

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: SearchViewModel(engine: engine))
  }

  var body: some View {
    ZStack(alignment: .top) {
      // === MAP ===
      Map(coordinateRegion: $region, annotationItems: vm.results) { position in
        MapAnnotation(coordinate: .init(latitude: position.lat, longitude: position.lng)) {
          Button {
            withAnimation(.easeInOut) {
              region.center = .init(latitude: position.lat, longitude: position.lng)
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

      // === BARRE DE RECHERCHE + FILTRES ===
      VStack(spacing: 10) {
        HStack(spacing: 10) {
          HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(Color(R.color.secondaryText))
            TextField(R.string.localizable.searchPlaceholder(), text: $vm.query)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              .focused($isSearchFocused)
              .onSubmit { Task { await vm.search() } }
          }
          .padding(.horizontal, 12)
          .frame(height: 44)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.25)))

          Button {
            Task { await vm.search() }
            isSearchFocused = false
          } label: {
            Text(R.string.localizable.searchActionCta())
          }
          .buttonStyle(PrimaryButton())

          Button { showFilters = true } label: {
            Image(systemName: "slider.horizontal.3")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(.black)
              .frame(width: 44, height: 44)
              .background(Color.gray.opacity(0.12))
              .clipShape(Circle())
          }
          .buttonStyle(HighlightButton())
          .accessibilityLabel(R.string.localizable.filterTitle())
        }
        .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
          VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
      }
      .padding(.top, 8)

      // === HORIZONTAL CARDS ===
      VStack {
        Spacer()

        if vm.isLoading {
          LoadingView()
            .padding(.bottom, 160) // éloigne du bas
        } else if vm.results.isEmpty {
          EmptyStateView(
            title: R.string.localizable.searchEmptyTitle(),
            message: R.string.localizable.searchEmptyMessage()
          )
          .padding(.bottom, 160)
          .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        } else {
          // ✅ Carrousel horizontal positionné plus haut
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
              ForEach(vm.results) { provider in
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
          // ⬆️ Positionné plus haut avec un espacement fixe sous les tabs
          .padding(.bottom, 160) // distance entre les cards et la tab bar
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

// Helper UIKit Blur
struct VisualEffectBlur: UIViewRepresentable {
  var blurStyle: UIBlurEffect.Style
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
  }
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
