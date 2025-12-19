// CompanyDashboardView.swift
import SwiftUI
import RswiftResources

struct CompanyDashboardView: View {
    @StateObject private var vm: CompanyDashboardViewModel

    // Sheets
    @State private var showFiltersSheet = false
    @State private var showLocationSheet = false
    @State private var showBudgetSheet = false

    init(engine: Engine) {
        _vm = StateObject(wrappedValue: CompanyDashboardViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // Fond clair pour toute la page (y compris le bas sous le contenu)
                Color(R.color.mainBackground.name)
                    .ignoresSafeArea()
                    // Bande noire juste en haut pour supprimer tout liseré blanc
                    .overlay(
                        Color.black
                            .frame(height: 200) // hauteur suffisante pour couvrir la zone du header + safe area
                            .ignoresSafeArea(edges: .top),
                        alignment: .top
                    )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header noir
                        header

                        // Contenu sur fond clair (hérite du fond global)
                        VStack(spacing: 20) {
                            // Décale les tabs vers le bas
                            tabs
                                .padding(.top, 12)

                            // Décale la rangée de filtres un peu plus bas aussi
                            filters
                                .padding(.top, 8)

                            if vm.isLoading {
                                ProgressView().padding(.top, 40)
                            } else {
                                offersList
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                // Pas de .background ici: on utilise le fond clair global
            }
            .navigationDestination(for: Offer.self) { offer in
                OfferDetailView(engine: vm.engine, offerId: offer.id)
            }
        }
        .task { await vm.load() }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // MARK: - Sheets
        .sheet(isPresented: $showFiltersSheet) { filtersSheet }
        .sheet(isPresented: $showLocationSheet) { locationSheet }
        .sheet(isPresented: $showBudgetSheet) { budgetSheet }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "building.2")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Entreprise")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Marketplace")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // Icône de notifications à la place du profil
                Image(systemName: "bell")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .overlay(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 8, y: -6)
                    )
                    .accessibilityLabel(Text("Notifications"))
            }

            Button(action: vm.onCreateOffer) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Créer une offre")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
    }

    // MARK: - Tabs
    private var tabs: some View {
        HStack(spacing: 0) {
            tabButton(.marketplace, title: "Offres du marché")
            tabButton(.myOffers, title: "Mes offres")
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(22)
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func tabButton(_ tab: CompanyDashboardViewModel.Tab, title: String) -> some View {
        Button {
            vm.selectedTab = tab
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(vm.selectedTab == tab ? .white : .gray)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    vm.selectedTab == tab ? Color.black : Color.clear
                )
                .cornerRadius(14)
        }
    }

    // MARK: - Filters (interactive)
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button { showFiltersSheet = true }  // Filtres (Type)
                label: { filterChip(titleForTypeChip, icon: "line.3.horizontal.decrease") }

                Button { showLocationSheet = true } // Localisation
                label: { filterChip(titleForLocationChip, icon: "location") }

                Button { showBudgetSheet = true }   // Budget
                label: { filterChip(titleForBudgetChip, icon: "eurosign") }
            }
            .padding(.horizontal, 20)
        }
    }

    private func filterChip(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.08))
        )
    }

    private var titleForTypeChip: String {
        if let tir = vm.selectedType { return tir.localizedTitle }
        return "Filtres"
    }
    private var titleForLocationChip: String {
        let que = vm.locationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return que.isEmpty ? "Localisation" : que
    }
    private var titleForBudgetChip: String {
        if let max = vm.budgetMax { return "≤ \(Int(max))€" }
        return "Budget"
    }

    // MARK: - Offers list
    private var offersList: some View {
        VStack(spacing: 16) {
            ForEach(vm.filteredCurrentOffers) { offer in
                NavigationLink(value: offer) {
                    OfferMarketplaceCardView(offer: offer)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Sheets
private extension CompanyDashboardView {

    // 1) Sheet Filtres (Type)
    var filtersSheet: some View {
        NavigationStack {
            Form {
                Section("Type d’offre") {
                    Picker("Type", selection: $vm.selectedType) {
                        Text("Tous").tag(nil as OfferType?)
                        ForEach(OfferType.allCases, id: \.self) { tie in
                            Text(tie.localizedTitle).tag(Optional(tie))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if vm.selectedType != nil {
                    Button("Effacer le type") { vm.selectedType = nil }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtres")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { showFiltersSheet = false }
                }
            }
        }
    }

    // 2) Sheet Localisation
    var locationSheet: some View {
        NavigationStack {
            Form {
                Section("Ville ou code postal") {
                    TextField("Bruxelles, 1000…", text: $vm.locationQuery)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                if !vm.locationQuery.isEmpty {
                    Button("Effacer la localisation") { vm.locationQuery = "" }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Localisation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { showLocationSheet = false }
                }
            }
        }
    }

    // 3) Sheet Budget (Prix max)
    var budgetSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let range = vm.availableBudgetRange {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prix max")
                            .font(.system(size: 17, weight: .semibold))
                        HStack {
                            Text("\(Int(range.min))€")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(range.max))€")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Slider(
                            value: Binding(
                                get: { vm.budgetMax ?? range.max },
                                set: { vm.budgetMax = $0 }
                            ),
                            in: range.min...range.max,
                            step: 5
                        )
                        .tint(.black)
                        HStack {
                            Text("Prix max sélectionné:")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("≤ \(Int((vm.budgetMax ?? range.max)))€")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    Text("Aucune offre pour calculer une plage de budget.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                }

                HStack(spacing: 12) {
                    Button("Réinitialiser") { vm.budgetMax = nil }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.2)))
                        .cornerRadius(12)

                    Button("Appliquer") { showBudgetSheet = false }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
            .padding(.top, 16)
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { showBudgetSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
