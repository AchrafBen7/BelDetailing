import SwiftUI
import RswiftResources

struct DashboardProviderView: View {
    
    @StateObject private var viewModel: ProviderDashboardViewModel
    @State private var showOffers = false
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: ProviderDashboardViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                // 🔥 FOND NOIR ABSOLU EN HAUT
                Color.black
                    .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 0) {
                    
                    // 🔥 HEADER COMPLET HORS SCROLL
                    ProviderDashboardHeaderView(
                        monthlyEarnings: 3250,
                        variationPercent: 12,
                        reservationsCount: 24,
                        rating: 4.8,
                        clientsCount: 87,
                        onViewOffers: { showOffers = true }
                    )
                    
                    // 🔥 CONTENU SCROLLABLE UNIQUEMENT (fond blanc)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            filterTabs
                            createButton
                            servicesListOrLoader
                        }
                        .padding(.top, 12)
                    }
                    .background(Color(R.color.mainBackground.name))
                }
            }
            .navigationDestination(isPresented: $showOffers) {
                OffersView(engine: viewModel.engine)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}



// MARK: - Subviews
private extension DashboardProviderView {
    
    // -----------------
    // 🔥 TABS
    // -----------------
    var filterTabs: some View {
        HStack(spacing: 14) {
            filterButton(.offers,   title: R.string.localizable.dashboardTabOffers())
            filterButton(.calendar, title: R.string.localizable.dashboardTabCalendar())
            filterButton(.stats,    title: R.string.localizable.dashboardTabStats())
            filterButton(.reviews,  title: R.string.localizable.dashboardTabReviews())
        }
        .padding(.horizontal, 20)
    }
    
    func filterButton(_ tab: ProviderDashboardFilter, title: String) -> some View {
        Button {
            viewModel.selectedFilter = tab
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)                 // ⬅️ empêche le texte de se couper
                .minimumScaleFactor(0.7)      // ⬅️ réduit légèrement si nécessaire
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(viewModel.selectedFilter == tab ? .black : .white)
                .foregroundColor(viewModel.selectedFilter == tab ? .white : .black)
                .cornerRadius(24)
                .shadow(color: .black.opacity(viewModel.selectedFilter == tab ? 0.15 : 0),
                        radius: 6, y: 3)

        }
    }
    
    // -----------------
    // 🔥 BOUTON CREER SERVICE
    // -----------------
    var createButton: some View {
        HStack {
            Text(R.string.localizable.dashboardMyServices())
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))
            Spacer()
            Button {
                print("Créer un service")
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)        // ⬅️ important
                    Text(R.string.localizable.dashboardCreateService())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)        // ⬅️ important
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 12)
                .background(Color.black)
                .cornerRadius(26)

            }
        }
        .padding(.horizontal, 20)
    }
    
    // -----------------
    // 🔥 LISTE SERVICES + LOADER
    // -----------------
    var servicesListOrLoader: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.services) { service in
                        ProviderServiceCardView(
                            service: service,
                            onEdit: { print("Edit \(service.id)") },
                            onDelete: { viewModel.deleteService(id: service.id) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
