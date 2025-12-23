import SwiftUI
import RswiftResources
import Combine

struct DashboardProviderView: View {

    @StateObject private var viewModel: ProviderDashboardViewModel
    @State private var showOffers = false
    
    init(engine: Engine, providerId: String) {
        _viewModel = StateObject(wrappedValue: ProviderDashboardViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Header simplifié
                    ProviderDashboardHeaderView(
                        onViewOffers: { showOffers = true }
                    )
                    Divider()
                        .padding(.horizontal, 20)

                    // CONTENT
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            filterTabs
                                .onReceive(NotificationCenter.default.publisher(for: .calendarMonthChanged)) { _ in
                                    viewModel.objectWillChange.send()
                                }
                            
                            switch viewModel.selectedFilter {
                            case .offers:
                                createButton
                                servicesListOrLoader
                                
                            case .calendar:
                                VStack(spacing: 16) {
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
                                MyReviewsView(engine: viewModel.engine)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 100)
                    }
                    .background(Color(R.color.mainBackground.name))
                }

                // Centered toast overlay (mood Uber)
                if let toast = viewModel.toast {
                    // Dim background (tap to dismiss)
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.toast = nil
                            }
                        }

                    CenterToast(toast: toast) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            viewModel.toast = nil
                        }
                    }
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
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
                    .padding(.bottom, 36)
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.bookingsForSelectedDate) { booking in
                        ProviderBookingCardView(
                            booking: booking,
                            onConfirm: { viewModel.confirmBooking(booking.id) },
                            onDecline: { viewModel.declineBooking(booking.id) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
    }
    
    // MARK: - SERVICES LIST
    private var servicesListOrLoader: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 32)
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
    
    // MARK: - FILTER TABS
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyle.Padding.small16.rawValue) {
                filterButton(.offers,   title: R.string.localizable.dashboardTabOffers())
                filterButton(.calendar, title: R.string.localizable.dashboardTabCalendar())
                filterButton(.stats,    title: R.string.localizable.dashboardTabStats())
                filterButton(.reviews,  title: R.string.localizable.dashboardTabReviews())
            }
            .padding(.horizontal, AppStyle.Padding.small16.rawValue)
            .padding(.vertical, 10)
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
// Bouton "Créer un service"
// -----------------
private var createButton: some View {
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

// MARK: - Center Toast (Uber-like)
private struct CenterToast: View {
    let toast: ToastState
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
                .padding(10)
                .background(Color.black.opacity(0.06))
                .clipShape(Circle())

            Text(toast.message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Button(action: onClose) {
                Text("OK")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(backgroundPlain)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
        .frame(maxWidth: 320)
        .frame(maxHeight: .infinity, alignment: .center)
    }

    // Fond blanc franc + fin contour gris clair
    private var backgroundPlain: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }

    private var iconName: String {
        switch toast.kind {
        case .error:   return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .info:    return "info.circle.fill"
        }
    }
}

// MARK: - MyReviewsView (JWT "me")
private struct MyReviewsView: View {
    let engine: Engine
    @State private var isLoading = false
    @State private var reviews: [Review] = []
    @State private var errorText: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView().padding(.top, 32)
            } else if let errorText {
                Text(errorText).foregroundColor(.red).padding()
            } else if reviews.isEmpty {
                Text("No reviews yet").foregroundColor(.gray).padding(.top, 32)
            } else {
                VStack(spacing: 12) {
                    ForEach(reviews) { review in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(review.customerName).font(.headline)
                            Text("⭐️ \(review.rating)")
                            if let rev = review.comment { Text(rev).font(.subheadline) }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        let resp = await engine.reviewService.getMyReviews()
        switch resp {
        case .success(let items):
            self.reviews = items
            self.errorText = nil
        case .failure(let err):
            self.reviews = []
            self.errorText = err.localizedDescription
        }
    }
}

