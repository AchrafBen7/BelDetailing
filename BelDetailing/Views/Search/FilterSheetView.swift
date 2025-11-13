import SwiftUI
import RswiftResources

struct FilterSheetView: View {
  @Binding var maxPrice: Double?
  @Binding var selectedCity: String?
  @Binding var atHome: Bool

  let cities: [City]
  var onClose: () -> Void

  @State private var priceValue: Double = 150
  private let minPrice: Double = 0
  private let maxPriceCap: Double = 300
  @State private var showOverlay = false

  // Fallback si aucune donnée API
  private var displayedCities: [City] {
    cities.isEmpty ? City.sampleValues : cities
  }

  // Groupement simple par région (déduit par nom)
  private var regions: [String: [City]] {
    Dictionary(grouping: displayedCities) { city in
      if ["Bruxelles"].contains(city.name) { return "Bruxelles" }
      if ["Liège", "Namur", "Charleroi", "Mons", "Tournai", "Arlon", "Bastogne", "Nivelles", "Dinant", "Wavre", "Louvain-la-Neuve"].contains(city.name) {
        return "Wallonie"
      }
      return "Flandre"
    }
  }

  var body: some View {
    ZStack(alignment: .top) {
      if showOverlay {
        Color.black.opacity(0.25)
          .ignoresSafeArea()
          .transition(.opacity)
      }

      VStack(spacing: 0) {
        NavigationStack {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {

              // === Budget ===
                VStack(alignment: .leading, spacing: 12) {
                  Text(R.string.localizable.filterBudgetTitle())
                    .font(AppStyle.TextStyle.sectionTitle.font)
                    .foregroundColor(.black)

                  // Affichage dynamique du range choisi
                  HStack {
                    Text("\(Int(priceValue))€")
                      .font(.system(size: 14, weight: .semibold))
                      .foregroundColor(.black)
                    Spacer()
                    Text("300€")
                      .font(.system(size: 14, weight: .semibold))
                      .foregroundColor(.black)
                  }

                  // Slider interactif
                  Slider(value: $priceValue, in: minPrice...maxPriceCap, step: 5)
                    .tint(.black)
                    .onChange(of: priceValue) { newValue in
                      maxPrice = newValue
                    }
                }


              // === Villes par région ===
              VStack(alignment: .leading, spacing: 20) {
                Text(R.string.localizable.filterCityTitle())
                  .font(AppStyle.TextStyle.sectionTitle.font)
                  .foregroundColor(.black)

                // Bouton global "Toutes les villes"
                FilterChip(
                  title: R.string.localizable.filterAllCities(),
                  isSelected: selectedCity == nil
                ) { selectedCity = nil }

                // Groupes par région
                ForEach(regions.keys.sorted(), id: \.self) { region in
                  VStack(alignment: .leading, spacing: 12) {
                    Text(region)
                      .font(.system(size: 16, weight: .semibold))
                      .foregroundColor(.gray)

                    let items = regions[region] ?? []
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                      ForEach(items) { city in
                        FilterChip(
                          title: city.name,
                          isSelected: selectedCity == city.name
                        ) { selectedCity = city.name }
                      }
                    }
                  }
                }
              }

              // === À domicile ===
              HStack(spacing: 12) {
                Image(systemName: "house.fill")
                  .font(.system(size: 18))
                  .foregroundColor(.black)
                Text(R.string.localizable.filterAtHome())
                  .font(.system(size: 15, weight: .medium))
                Spacer()
                Toggle("", isOn: $atHome)
                  .labelsHidden()
              }
              .padding()
              .background(Color.gray.opacity(0.08))
              .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            .padding(.vertical, AppStyle.Padding.small16.rawValue)
          }
          .background(Color.white)
          .navigationTitle(Text(R.string.localizable.filterTitle().capitalized + "."))
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
              Button(action: { onClose() }) {
                Image(systemName: "xmark")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.black)
                  .padding(8)
                  .background(Color.white.opacity(0.9))
                  .clipShape(Circle())
                  .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
              }
            }
          }
        }

        // === Bouton Appliquer ===
        VStack {
          Button(action: { onClose() }) {
            Text(R.string.localizable.searchActionCta())
              .font(.system(size: 17, weight: .semibold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.black)
              .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          }
        }
        .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        .padding(.vertical, 12)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
      }
    }
    .onAppear {
      if let current = maxPrice { priceValue = current }
      withAnimation(.easeIn(duration: 0.25)) { showOverlay = true }
    }
    .onDisappear {
      withAnimation(.easeOut(duration: 0.25)) { showOverlay = false }
    }
  }
}
