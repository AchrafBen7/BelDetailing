import SwiftUI
import RswiftResources

struct BookingsView: View {
    
    @StateObject private var viewModel: BookingsViewModel
    @State private var selectedFilter: BookingFilter = .all
    @Namespace private var tabsNS
    @State private var showCancelSheet = false
    @State private var bookingToCancel: Booking? = nil
    @State private var bookingToManage: Booking? = nil
    @State private var showTooLateAlert = false
    
    @State private var selectedBooking: Booking? = nil
    
    let engine: Engine
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: BookingsViewModel(engine: engine))
        self.engine = engine
    }
    
    @StateObject private var badgeManager = NotificationBadgeManager.shared
    
    var body: some View {
        NavigationStack {
            mainContent
                .background(Color.white)
                .toolbar(.hidden, for: .navigationBar)
                .task {
                    print("🧩 [View] .task triggered")
                    await viewModel.loadIfNeeded()
                    badgeManager.resetBookingBadge()
                }
                .sheet(item: $selectedBooking) { booking in
                    BookingDetailView(booking: booking, engine: engine)
                }
                .onChange(of: selectedBooking) { newValue in
                    if newValue == nil {
                        Task { await viewModel.reload() }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .bookingCreated)) { _ in
                    Task { await viewModel.reload() }
                }
        }
        .sheet(item: $bookingToCancel) { booking in
            BookingCancelSheetView(booking: booking, engine: engine)
        }
        .onChange(of: bookingToCancel) { newValue in
            if newValue == nil {
                Task { await viewModel.reload() }
            }
        }
        .sheet(item: $bookingToManage) { booking in
            BookingManageSheetView(booking: booking, engine: engine)
        }
        .onChange(of: bookingToManage) { newValue in
            if newValue == nil {
                Task { await viewModel.reload() }
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            tabs
            bookingsList
            Spacer(minLength: 0)
        }
    }
    
    private var bookingsList: some View {
        ScrollView(showsIndicators: false) {
            listContent
        }
        .refreshable {
            await viewModel.reload()
        }
        .frame(maxHeight: .infinity)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var listContent: some View {
        if viewModel.isLoading {
            SkeletonLoadingView(itemCount: 3)
                .padding(.top, 20)
        } else if viewModel.errorText != nil {
            ErrorStateView.networkError {
                Task {
                    await viewModel.reload()
                }
            }
            .padding(.top, 60)
        } else if filteredBookings.isEmpty {
            emptyState
        } else {
            bookingsListContent
        }
    }
    
    private var bookingsListContent: some View {
        LazyVStack(spacing: 20) {
            ForEach(filteredBookings, id: \.id) { booking in
                bookingCard(for: booking)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func bookingCard(for booking: Booking) -> some View {
        if selectedFilter == .counterProposals {
            CounterProposalCardView(
                booking: booking,
                onAccept: {
                    Task {
                        await viewModel.acceptCounterProposal(bookingId: booking.id)
                        await viewModel.reload()
                    }
                },
                onRefuse: {
                    Task {
                        await viewModel.refuseCounterProposal(bookingId: booking.id)
                        await viewModel.reload()
                    }
                },
                onTap: {
                    selectedBooking = booking
                }
            )
        } else {
            BookingCardView(
                booking: booking,
                onManage: {
                    handleManageAction(for: booking)
                },
                onCancel: {
                    handleCancelAction(for: booking)
                },
                onRepeat: {
                    print("BOOK AGAIN \(booking.id)")
                }
            )
            .errorAlert(
                isPresented: $showTooLateAlert,
                title: R.string.localizable.bookingTooLateTitle(),
                message: R.string.localizable.bookingTooLateMessage(),
                primaryAction: R.string.localizable.commonOk(),
                primaryActionHandler: nil
            )
        }
    }
    
    // MARK: - Actions
    
    private func handleManageAction(for booking: Booking) {
        if booking.isWithin24h {
            showTooLateAlert = true
        } else {
            bookingToManage = booking
        }
    }
    
    private func handleCancelAction(for booking: Booking) {
        if booking.isWithin24h {
            showTooLateAlert = true
        } else {
            bookingToCancel = booking
            showCancelSheet = true
        }
    }
}

private extension BookingsView {
    var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Spacer()
            
            Text(R.string.localizable.tabBookings())
                .font(DesignSystem.Typography.navigationTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Spacer()
            
            Button {
                // Recherche (à implémenter si nécessaire)
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
    }
    var tabs: some View {
        let isCustomer = AppSession.shared.user?.role == .customer
        let availableFilters = isCustomer ? BookingFilter.allCases : BookingFilter.allCases.filter { $0 != .counterProposals }
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(availableFilters, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.title)
                            .font(DesignSystem.Typography.chipLabel)
                            .foregroundColor(
                                selectedFilter == filter
                                    ? .white
                                    : DesignSystem.Colors.primaryText
                            )
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                selectedFilter == filter
                                    ? DesignSystem.Colors.primary
                                    : DesignSystem.Colors.cardBackground
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                                    .stroke(
                                        selectedFilter == filter
                                            ? Color.clear
                                            : DesignSystem.Colors.border,
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }
    var filteredBookings: [Booking] {
        let result: [Booking]
        switch selectedFilter {
        case .all:       result = viewModel.allBookings
        case .pending:   result = viewModel.pending
        case .upcoming:  result = viewModel.upcoming
        case .ongoing:   result = viewModel.ongoing
        case .completed: result = viewModel.completed
        case .counterProposals:
            result = viewModel.allBookings.filter { booking in
                booking.counterProposalStatus == .pending
            }
        }
        print("🧮 [View] filtered for \(selectedFilter) ->", result.count)
        return result
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(R.string.localizable.bookingsEmptyTitle())
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(R.string.localizable.bookingsEmptyMessage())
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

enum BookingFilter: CaseIterable {
    case all, pending, upcoming, ongoing, completed, counterProposals
    var title: String {
        switch self {
        case .all:       return R.string.localizable.filterAll()
        case .pending:   return R.string.localizable.bookingStatusPending()
        case .upcoming:  return R.string.localizable.bookingStatusConfirmed()
        case .ongoing:   return R.string.localizable.bookingStatusDeclined()
        case .completed: return R.string.localizable.bookingStatusCompleted()
        case .counterProposals: return "Contre-propositions"
        }
    }
}
