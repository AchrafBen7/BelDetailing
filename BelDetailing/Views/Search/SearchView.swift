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

  // Région défaut: Bruxelles
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517),
    span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
  )

  // Draggable sheet
  @State private var sheetHeight: CGFloat = 220
  private let minSheetHeight: CGFloat = 140
  private let maxSheetHeight: CGFloat = 420

  // Filter sheet
  @State private var showFilters = false

  init(engine: Engine) {
    _vm = StateObject(wrappedValue: SearchViewModel(engine: engine))
  }

  var body: some View {
    ZStack(alignment: .top) {
      // MARK: Map plein écran
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

      // MARK: Barre recherche + bouton filtre (overlay top)
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

      // MARK: Sheet de cards (overlay bottom) — fluide & sans voile
      GeometryReader { proxy in
        let safeBottom = proxy.safeAreaInsets.bottom
        let totalHeight = maxSheetHeight + safeBottom

        VStack(spacing: 0) {
          // Handle
          Capsule()
            .fill(Color.gray.opacity(0.35))
            .frame(width: 42, height: 5)
            .padding(.vertical, 8)

          // Contenu
          if vm.isLoading {
            LoadingView().padding(.top, 8); Spacer()
          } else if vm.results.isEmpty {
            EmptyStateView(
              title: R.string.localizable.searchEmptyTitle(),
              message: R.string.localizable.searchEmptyMessage()
            )
            .padding(); Spacer()
          } else {
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
              .padding(.vertical, AppStyle.Padding.small16.rawValue)
            }
          }
        }
        .frame(height: totalHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(Color.clear)         // ⬅️ pas de voile/blanc
        .offset(y: proxy.size.height - sheetHeight - safeBottom)
        .gesture(
          DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged { value in
              let newHeight = sheetHeight - value.translation.height
              sheetHeight = min(max(newHeight, minSheetHeight), maxSheetHeight)
            }
            .onEnded { value in
              // ⬇️ Anim fluide avec “vitesse” (comme Apple Plans)
              let predicted = value.predictedEndTranslation.height
              let target: CGFloat
              if predicted > 150 {
                target = minSheetHeight
              } else if predicted < -150 {
                target = maxSheetHeight
              } else {
                let mid = (minSheetHeight + maxSheetHeight) / 2
                target = sheetHeight < mid ? maxSheetHeight : minSheetHeight
              }
              withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                sheetHeight = target
              }
            }
        )
        .ignoresSafeArea(edges: .bottom)
      }
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

// Blur helper
struct VisualEffectBlur: UIViewRepresentable {
  var blurStyle: UIBlurEffect.Style
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
  }
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
