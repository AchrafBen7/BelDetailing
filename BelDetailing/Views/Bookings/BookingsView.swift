import SwiftUI
import RswiftResources

struct BookingsView: View {
    
    @StateObject private var viewModel: BookingsViewModel
    @State private var selectedFilter: BookingFilter = .all
    @Namespace private var tabsNS
    @State private var showCancelSheet = false
    @State private var bookingToCancel: Booking? = nil
    @State private var showTooLateAlert = false
    
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
                
                // LIST
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredBookings, id: \.id) { booking in
                            BookingCardView(
                                booking: booking,
                                onManage: {
                                    if booking.isWithin24h {
                                        print("Impossible de modifier, moins de 24h")
                                    } else {
                                        selectedBooking = booking
                                    }
                                },
                                onCancel: {
                                    if booking.isWithin24h {
                                        showTooLateAlert = true
                                    } else {
                                        bookingToCancel = booking
                                        showCancelSheet = true
                                    }
                                },
                                onRepeat: {
                                    print("BOOK AGAIN \(booking.id)")
                                }
                            )
                            .background(Color.yellow.opacity(0.08))
                            .alert("Impossible", isPresented: $showTooLateAlert) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Vous ne pouvez plus annuler ou modifier une réservation dans les 24 heures précédant l'heure prévue.")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .refreshable {
                    await viewModel.reload()
                }
                .frame(maxHeight: .infinity)
                .background(Color.white)
                
                // Fallback pour forcer l’expansion
                Spacer(minLength: 0)
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                print("🧩 [View] .task triggered")
                await viewModel.loadIfNeeded()
            }
            .sheet(item: $selectedBooking) { booking in
                BookingManageSheetView(
                    booking: booking,
                    engine: engine
                )
            }
            // When sheet closes, refresh to reflect changes
            .onChange(of: selectedBooking) { newValue in
                if newValue == nil {
                    Task { await viewModel.reload() }
                }
            }
            // Ecoute la création d’une réservation ailleurs dans l’app
            .onReceive(NotificationCenter.default.publisher(for: .bookingCreated)) { _ in
                Task { await viewModel.reload() }
            }
        }
        .sheet(item: $bookingToCancel) { booking in
            BookingCancelSheetView(booking: booking)
        }
        // When cancel sheet closes, refresh to reflect changes
        .onChange(of: bookingToCancel) { newValue in
            if newValue == nil {
                Task { await viewModel.reload() }
            }
        }
    }
}

private extension BookingsView {
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
    var filteredBookings: [Booking] {
        let result: [Booking]
        switch selectedFilter {
        case .all:       result = viewModel.allBookings
        case .pending:   result = viewModel.pending
        case .upcoming:  result = viewModel.upcoming
        case .ongoing:   result = viewModel.ongoing
        case .completed: result = viewModel.completed
        }
        print("🧮 [View] filtered for \(selectedFilter) ->", result.count)
        return result
    }
}

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
