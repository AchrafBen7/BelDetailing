import SwiftUI
import Combine
import RswiftResources

struct CustomerDashboardView: View {
    let engine: Engine
    @StateObject private var vm: CustomerDashboardViewModel

    init(engine: Engine) {
        self.engine = engine
        _vm = StateObject(wrappedValue: CustomerDashboardViewModel(engine: engine))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    quickActions
                    upcomingBookings
                    recommendedProviders
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color(R.color.mainBackground.name))
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inline)
        }
        .task { await vm.load() }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)

            Text(vm.displayName)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 12) {
            Button(action: vm.onBookService) {
                ActionCard(title: "Book a service", icon: "calendar.badge.plus", color: .black)
            }
            Button(action: vm.onViewBookings) {
                ActionCard(title: "My bookings", icon: "calendar", color: .blue)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Upcoming bookings
    private var upcomingBookings: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Upcoming bookings")
                .padding(.horizontal, 20)

            Group {
                if vm.isLoadingBookings {
                    ProgressView().padding(.top, 24)
                } else if vm.bookings.isEmpty {
                    EmptyStateView(
                        title: "No upcoming bookings",
                        message: "When you book a service, it will appear here."
                    )
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(vm.bookings) { booking in
                            BookingRowView(booking: booking)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(Color.white)
    }

    // MARK: - Recommended providers
    private var recommendedProviders: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Recommended providers")
                .padding(.horizontal, 20)

            Group {
                if vm.isLoadingProviders {
                    ProgressView().padding(.top, 24)
                } else if vm.providers.isEmpty {
                    EmptyStateView(
                        title: "No recommendations yet",
                        message: "We’ll suggest providers based on your location and history."
                    )
                    .padding(.horizontal, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.providers) { provider in
                                ProviderCardView(provider: provider)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .padding(.top, 8)
        .background(Color.white)
    }
}

// MARK: - UI helpers
private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(Color(R.color.primaryText))
    }
}

private struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

private struct BookingRowView: View {
    let booking: Booking
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.displayServiceName)
                    .font(.system(size: 16, weight: .semibold))
                Text("\(booking.date) • \(booking.displayStartTime)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

private struct ProviderCardView: View {
    let provider: Detailer
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: 180, height: 100)
                .overlay(
                    Image(systemName: "car.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.gray)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(provider.displayName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(R.color.primaryText))

            HStack(spacing: 6) {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12))
                Text(String(format: "%.1f", provider.rating))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .frame(width: 180)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
