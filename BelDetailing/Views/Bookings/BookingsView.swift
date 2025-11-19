import SwiftUI
import RswiftResources

struct BookingsView: View {
    
    @StateObject private var viewModel: BookingsViewModel
    @State private var selectedFilter: BookingFilter = .all
    @Namespace private var tabsNS
    @State private var showCancelSheet = false
    @State private var bookingToCancel: Booking? = nil

    
    // 👉 Pour ouvrir la page de gestion
    @State private var selectedBooking: Booking? = nil
    
    let engine: Engine
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: BookingsViewModel(engine: engine))
        self.engine = engine
    }
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 0) {
                
                header
                tabs
                
                // --- LISTE ---
                List {
                    ForEach(filteredBookings) { booking in
                        
                        BookingCardView(
                            booking: booking,
                            onManage: {
                                selectedBooking = booking
                            },
                            onCancel: {
                                bookingToCancel = booking      // 👉 on set la réservation en cours
                                showCancelSheet = true         // 👉 on ouvre la sheet
                            }
                        )

                        
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
            
            // MARK: - NAVIGATION TO MANAGE VIEW
            .navigationDestination(item: $selectedBooking) { booking in
                BookingManageView(
                    booking: booking,
                    engine: engine
                )
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
        .sheet(isPresented: $showCancelSheet) {
            if let booking = bookingToCancel {
                BookingCancelSheetView(booking: booking)
            }
        }

    }
}
// MARK: - Subviews + Helpers
private extension BookingsView {
    // MARK: HEADER
    var header: some View {
        HStack {
            (R.string.localizable.tabBookings() + ".")
                .textView(style: .heroTitle)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20, weight: .semibold))
                .overlay(
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 8, y: -6)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    // MARK: TABS
    var tabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    VStack(spacing: 6) {
                        Text(filter.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedFilter == filter ? .black : .gray)
                        ZStack {
                            if selectedFilter == filter {
                                Capsule()
                                    .fill(Color.black)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "underline", in: tabsNS)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
    // MARK: FILTERED BOOKINGS
    var filteredBookings: [Booking] {
        switch selectedFilter {
        case .all:
            return viewModel.allBookings
        case .pending:
            return viewModel.pending
        case .upcoming:
            return viewModel.upcoming
        case .ongoing:
            return viewModel.ongoing
        case .completed:
            return viewModel.completed
        }
    }
}

// MARK: - Filter enum
enum BookingFilter: CaseIterable {
    case all, pending, upcoming, ongoing, completed
    var title: String {
        switch self {
        case .all:       return R.string.localizable.filterAll()
        case .pending:   return R.string.localizable.bookingStatusPending()
        case .upcoming:  return R.string.localizable.bookingStatusConfirmed()
        case .ongoing:   return R.string.localizable.bookingStatusDeclined()
        case .completed: return R.string.localizable.bookingStatusCompleted()
        }
    }
}
