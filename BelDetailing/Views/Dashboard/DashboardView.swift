import SwiftUI
import RswiftResources
import Combine

struct DashboardProviderView: View {

    @StateObject private var viewModel: ProviderDashboardViewModel
    @State private var showOffers = false
    
    init(engine: Engine, providerId: String) {
        // providerId no longer needed; keep init signature for now to avoid breaking callers
        _viewModel = StateObject(wrappedValue: ProviderDashboardViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                Color.black.ignoresSafeArea(edges: .top)
                
                VStack(spacing: 0) {
                    
                    // ✅ HEADER DYNAMIQUE (mapping DetailerStats → header)
                    ProviderDashboardHeaderView(
                        monthlyEarnings: viewModel.stats?.monthlyEarnings ?? 0,
                        variationPercent: viewModel.stats?.variationPercent ?? 0,
                        reservationsCount: viewModel.stats?.reservationsCount ?? 0,
                        rating: viewModel.stats?.rating ?? 0,
                        clientsCount: viewModel.stats?.clientsCount ?? 0,
                        onViewOffers: { showOffers = true }
                    )
                    
                    // CONTENT
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            
                            filterTabs
                                .onReceive(NotificationCenter.default.publisher(for: .calendarMonthChanged)) { _ in
                                    viewModel.objectWillChange.send()
                                }
                            
                            switch viewModel.selectedFilter {
                                
                            case .offers:
                                createButton
                                servicesListOrLoader
                                
                            case .calendar:
                                VStack(spacing: 20) {
                                    ProviderMonthCalendarView(
                                        selectedDate: $viewModel.selectedDate,
                                        status: viewModel.calendarStatus(forMonth: viewModel.selectedDate)
                                    )
                                    bookingsList
                                }
                                
                            case .stats:
                                StatsPlaceholder(
                                    stats: viewModel.stats,
                                    popularServices: viewModel.popularServices
                                )

                            case .reviews:
                                ProviderReviewsView(
                                    engine: viewModel.engine,
                                    providerId: "" // public reviews may still require id; replace when wiring JWT/me reviews
                                )
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 120)
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
    
    // MARK: - BOOKINGS LIST
    private var bookingsList: some View {
        Group {
            if viewModel.bookingsForSelectedDate.isEmpty {
                Text(R.string.localizable.dashboardNoBookings())
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .padding(.bottom, 40)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.bookingsForSelectedDate) { booking in
                        ProviderBookingCardView(
                            booking: booking,
                            onConfirm: { viewModel.confirmBooking(booking.id) },
                            onDecline: { viewModel.declineBooking(booking.id) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - SERVICES LIST
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
    
    // MARK: - FILTER TABS
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyle.Padding.small16.rawValue) {
                filterButton(.offers,   title: R.string.localizable.dashboardTabOffers())
                filterButton(.calendar,   title: R.string.localizable.dashboardTabCalendar())
                filterButton(.stats,      title: R.string.localizable.dashboardTabStats())
                filterButton(.reviews,    title: R.string.localizable.dashboardTabReviews())
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            .padding(.vertical, AppStyle.Padding.small16.rawValue)
            .background(Color.white)
        }
    }
    private func filterButton(_ tab: ProviderDashboardFilter, title: String) -> some View {
        FilterChip(
            title: title,
            isSelected: viewModel.selectedFilter == tab,
            action: { viewModel.selectedFilter = tab }
        )
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
                    .foregroundColor(.white)
                Text(R.string.localizable.dashboardCreateService())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(Color.black)
            .cornerRadius(26)
        }
    }
    .padding(.horizontal, 20)
}

