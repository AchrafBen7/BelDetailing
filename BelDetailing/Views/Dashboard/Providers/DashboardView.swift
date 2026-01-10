import SwiftUI
import RswiftResources
import Combine

struct DashboardProviderView: View {

    @StateObject private var viewModel: ProviderDashboardViewModel
    @State private var showOffers = false
    @State private var showCreateService = false
    @State private var selectedBooking: Booking?

    init(engine: Engine, providerId: String) {
        _viewModel = StateObject(
            wrappedValue: ProviderDashboardViewModel(engine: engine)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {

                VStack(spacing: 0) {

                    // HEADER
                    ProviderDashboardHeaderView(
                        onViewOffers: { showOffers = true }
                    )

                    Divider()
                        .padding(.horizontal, 20)

                    // CONTENT
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            filterTabs

                            switch viewModel.selectedFilter {

                            case .offers:
                                createButton
                                servicesListOrLoader

                            case .calendar:
                                ProviderAvailabilityView(engine: viewModel.engine)

                            case .stats:
                                ProviderStatsView(engine: viewModel.engine)

                            case .reviews:
                                reviewsSection
                            
                            case .stripe:
                                ProviderStripeView(engine: viewModel.engine)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }

                // TOAST
                if let toast = viewModel.toast {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.toast = nil
                        }

                    CenterToast(toast: toast) {
                        viewModel.toast = nil
                    }
                }
            }
            .sheet(item: $selectedBooking) { booking in
                BookingDetailView(booking: booking, engine: viewModel.engine)
            }
            .navigationDestination(isPresented: $showCreateService) {
                ProviderCreateServiceView(engine: viewModel.engine) {
                    await viewModel.loadServices()
                }
            }
            .navigationDestination(isPresented: $showOffers) {
                OffersView(engine: viewModel.engine)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - CREATE SERVICE BUTTON
    private var createButton: some View {
        HStack {
            Text(R.string.localizable.dashboardMyServices())
                .font(.system(size: 22, weight: .semibold))

            Spacer()

            Button {
                showCreateService = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text(R.string.localizable.dashboardCreateService())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 26)
                .padding(.vertical, 12)
                .background(Color.black)
                .cornerRadius(26)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - CALENDAR SECTION
    private var calendarSection: some View {
        VStack(spacing: 16) {
            ProviderMonthCalendarView(
                selectedDate: $viewModel.selectedDate,
                status: viewModel.calendarStatus(
                    forMonth: viewModel.selectedDate
                ),
                onDateTap: nil
            )
            bookingsList
        }
    }

    // MARK: - BOOKINGS LIST
    private var bookingsList: some View {
        Group {
            if viewModel.bookingsForSelectedDate.isEmpty {
                Text(R.string.localizable.dashboardNoBookings())
                    .foregroundColor(.gray)
                    .padding(.top, 32)
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.bookingsForSelectedDate) { booking in
                        ProviderBookingCardView(
                            booking: booking,
                            onConfirm: { viewModel.confirmBooking(booking.id) },
                            onDecline: { viewModel.declineBooking(booking.id) },
                            onTap: {
                                selectedBooking = booking
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - SERVICES LIST
    private var servicesListOrLoader: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().padding(.top, 32)
            } else {
                VStack(spacing: 14) {
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

    // MARK: - REVIEWS SECTION (réel)
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.detailReviewsTitle())
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)

            if viewModel.isLoadingReviews {
                ProgressView()
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
            } else if viewModel.myReviews.isEmpty {
                Text("Aucun avis pour le moment.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.myReviews) { review in
                        ReviewCardView(review: review)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    // MARK: - FILTER TABS
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                filterButton(.offers, title: R.string.localizable.dashboardTabOffers())
                filterButton(.calendar, title: R.string.localizable.dashboardTabCalendar())
                filterButton(.stats, title: R.string.localizable.dashboardTabStats())
                filterButton(.reviews, title: R.string.localizable.dashboardTabReviews())
                filterButton(.stripe, title: R.string.localizable.dashboardTabStripe())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }

    private func filterButton(
        _ tab: ProviderDashboardFilter,
        title: String
    ) -> some View {
        FilterChip(
            title: title,
            isSelected: viewModel.selectedFilter == tab,
            action: { viewModel.selectedFilter = tab }
        )
    }
}

struct CenterToast: View {
    let toast: ToastState
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(toast.message)
                .font(.headline)

            Button("OK", action: onClose)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

struct MyReviewsView: View {
    let engine: Engine

    var body: some View {
        Text("Avis du prestataire")
            .foregroundColor(.gray)
            .padding(.top, 40)
    }
}

