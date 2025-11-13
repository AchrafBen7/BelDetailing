//
//  FilterSheetView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 13/11/2025.
//

import SwiftUI
import RswiftResources

struct FilterSheetView: View {
  @Binding var maxPrice: Double?
  @Binding var selectedCity: String?
  @Binding var atHome: Bool

  let cities: [City]
  var onClose: () -> Void

  // slider state interne (value affichée même si maxPrice == nil)
  @State private var priceValue: Double = 150
  private let minPrice: Double = 0
  private let maxPriceCap: Double = 300

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {

          // Budget
          VStack(alignment: .leading, spacing: 10) {
            Text(R.string.localizable.filterBudgetTitle())
              .font(AppStyle.TextStyle.sectionTitle.font)

            HStack {
              Text("€\(Int(minPrice))")
              Spacer()
              Text("€\(Int(maxPriceCap))")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(R.color.secondaryText))

            Slider(value: $priceValue, in: minPrice...maxPriceCap, step: 5)
              .onChange(of: priceValue) { newValue in
                maxPrice = newValue
              }
          }

          // Villes
          VStack(alignment: .leading, spacing: 12) {
            Text(R.string.localizable.filterCityTitle())
              .font(AppStyle.TextStyle.sectionTitle.font)

            // Grille de chips
            let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
              // "Toutes les villes"
              FilterChip(
                title: R.string.localizable.filterAllCities(),
                isSelected: selectedCity == nil
              ) { selectedCity = nil }

              ForEach(cities) { city in
                FilterChip(
                  title: city.name,
                  isSelected: selectedCity == city.name
                ) { selectedCity = city.name }
              }
            }
          }

          // À domicile
          HStack(spacing: 12) {
            Image(systemName: "house.fill")
              .font(.system(size: 18))
            Text(R.string.localizable.filterAtHome())
              .font(AppStyle.TextStyle.buttonSecondary.font)
            Spacer()
            Toggle("", isOn: $atHome)
              .labelsHidden()
          }
          .padding()
          .background(Color.gray.opacity(0.08))
          .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.horizontal, AppStyle.Padding.small16.rawValue)
        .padding(.top, AppStyle.Padding.small16.rawValue)
        .padding(.bottom, AppStyle.Padding.small16.rawValue)
      }
      .navigationTitle(R.string.localizable.filterTitle())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(R.string.localizable.close()) { onClose() }
        }
      }
    }
    .onAppear {
      if let current = maxPrice { priceValue = current }
    }
  }
}
