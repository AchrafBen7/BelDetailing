import SwiftUI
import RswiftResources

struct BookingsView: View {
    @StateObject private var viewModel: BookingsViewModel
    @State private var selectedFilter: BookingFilter = .all
    @Namespace private var tabsNS
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: BookingsViewModel(engine: engine))
    }
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                tabs
                // ⚡️ LISTE qui active les swipeActions
                List {
                    ForEach(filteredBookings) { booking in
                        BookingCardView(
                            booking: booking,
                            onTap: {
                                print("DETAIL booking \(booking.id)")
                            }
                        )
                        .listRowSeparator(.hidden)       // on cache le séparateur
                        .listRowBackground(Color.clear) // fond transparent
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                print("Cancel booking \(booking.id)")
                                // plus tard : viewModel.cancelBooking(booking.id)
                            } label: {
                                Label(
                                    R.string.localizable.bookingCancel(),
                                    systemImage: "xmark.circle.fill"
                                )
                                .labelStyle(.iconOnly)
                                .font(.system(size: 26))
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(.plain)  // style moderne iOS
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            await viewModel.loadIfNeeded()
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
