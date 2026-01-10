//
//  ProviderAvailabilityView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import Combine
import EventKit

// MARK: - Identifiable Date Wrapper
private struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct ProviderAvailabilityView: View {
    @StateObject private var viewModel: ProviderAvailabilityViewModel
    @State private var selectedDateForBookings: IdentifiableDate?
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: ProviderAvailabilityViewModel(engine: engine))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Synchronisation calendrier iPhone
                calendarSyncSection
                
                // Calendrier avec disponibilités
                calendarSection
                
                // Heures d'ouverture
                openingHoursSection
                
                // Créneaux bloqués
                blockedSlotsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedDateForBookings) { identifiableDate in
                PendingBookingsSheetView(
                    date: identifiableDate.date,
                    bookings: viewModel.pendingBookings(for: identifiableDate.date),
                    engine: viewModel.engine,
                    viewModel: viewModel,
                    onConfirm: { @MainActor bookingId in
                        print("🟢 [ProviderAvailabilityView] onConfirm callback START - id: '\(bookingId)'")
                        print("🟢 [ProviderAvailabilityView] viewModel: \(type(of: viewModel))")
                        print("🟢 [ProviderAvailabilityView] On MainActor, calling confirmBooking...")
                        await viewModel.confirmBooking(bookingId)
                        print("🟢 [ProviderAvailabilityView] confirmBooking returned, checking errorMessage: \(viewModel.errorMessage ?? "nil")")
                        print("🟢 [ProviderAvailabilityView] reloading...")
                        await viewModel.load()
                        print("🟢 [ProviderAvailabilityView] load() completed")
                    },
                    onDecline: { @MainActor bookingId in
                        print("🟢 [ProviderAvailabilityView] onDecline callback START - id: '\(bookingId)'")
                        print("🟢 [ProviderAvailabilityView] viewModel: \(type(of: viewModel))")
                        print("🟢 [ProviderAvailabilityView] On MainActor, calling declineBooking...")
                        await viewModel.declineBooking(bookingId)
                        print("🟢 [ProviderAvailabilityView] declineBooking returned, checking errorMessage: \(viewModel.errorMessage ?? "nil")")
                        print("🟢 [ProviderAvailabilityView] reloading...")
                        await viewModel.load()
                        print("🟢 [ProviderAvailabilityView] load() completed")
                    },
                    onCounterPropose: { booking in
                        // Le sheet sera géré par PendingBookingsSheetView
                    }
                )
        }
    }
    
    // MARK: - Calendar Sync Section
    private var calendarSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.calendarSyncTitle())
                        .font(.system(size: 18, weight: .semibold))
                    Text(R.string.localizable.calendarSyncDescription())
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.isCalendarSyncEnabled },
                    set: { newValue in
                        Task {
                            await viewModel.toggleCalendarSync(enabled: newValue)
                        }
                    }
                ))
            }
            
            if viewModel.calendarSyncStatus == .denied {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(R.string.localizable.calendarSyncDenied())
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            } else if viewModel.calendarSyncStatus == .authorized && viewModel.isCalendarSyncEnabled {
                if let syncedCount = viewModel.syncedBookingsCount {
                    Text(R.string.localizable.calendarSyncCount(syncedCount))
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Calendar Section (Amélioré - Plus visible et central)
    private var calendarSection: some View {
        VStack(spacing: 20) {
            // Titre avec statistiques rapides
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(R.string.localizable.availabilityTitle())
                        .font(.system(size: 24, weight: .bold))
                    
                    // Statistiques rapides
                    HStack(spacing: 16) {
                        StatBadge(
                            count: viewModel.bookings.filter { $0.status == .pending && !$0.isExpired }.count,
                            label: R.string.localizable.availabilityPending(),
                            color: .orange
                        )
                        StatBadge(
                            count: viewModel.bookings.filter { $0.status == .confirmed || $0.status == .started || $0.status == .inProgress }.count,
                            label: R.string.localizable.availabilityConfirmed(),
                            color: .green
                        )
                    }
                    .padding(.top, 4)
                }
                Spacer()
            }
            
            // Calendrier agrandi et plus visible
            VStack(spacing: 16) {
                ProviderMonthCalendarView(
                    selectedDate: $viewModel.selectedDate,
                    status: viewModel.calendarStatus(forMonth: viewModel.selectedDate),
                    onDateTap: { date in
                        // Vérifier si la date a des bookings pending
                        let pendingBookings = viewModel.pendingBookings(for: date)
                        if !pendingBookings.isEmpty {
                            selectedDateForBookings = IdentifiableDate(date: date)
                        } else {
                            viewModel.selectedDate = date
                        }
                    }
                )
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Légende améliorée
                legend
            }
            
            // Réservations du jour sélectionné
            let selectedDateBookings = bookingsForSelectedDate
            if !selectedDateBookings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(R.string.localizable.availabilityBookingsForDate(formatDateOnly(DateFormatters.onlyDate(viewModel.selectedDate))))
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 8)
                    
                    ForEach(selectedDateBookings.prefix(3)) { booking in
                        BookingQuickCard(booking: booking)
                    }
                    
                    if selectedDateBookings.count > 3 {
                        Text(R.string.localizable.availabilityMoreBookings(selectedDateBookings.count - 3))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
    }
    
    // Helper pour les statistiques
    private var bookingsForSelectedDate: [Booking] {
        let dateString = DateFormatters.onlyDate(viewModel.selectedDate)
        return viewModel.bookings
            .filter { $0.date == dateString }
            .sorted { ($0.startTime ?? "00:00") < ($1.startTime ?? "00:00") }
    }
    
    // Helper pour formater une date sans heure
    private func formatDateOnly(_ dateString: String) -> String {
        guard let date = DateFormatters.isoDate(dateString) else {
            return dateString
        }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = DateFormatters.tz
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Legend (Améliorée)
    private var legend: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                legendItem(color: .green, text: R.string.localizable.availabilityConfirmed())
                legendItem(color: .orange, text: R.string.localizable.availabilityPending())
            }
            HStack(spacing: 16) {
                legendItem(color: .red, text: R.string.localizable.availabilityBlocked())
                legendItem(color: .gray, text: R.string.localizable.availabilityAvailable())
            }
        }
        .font(.system(size: 13, weight: .medium))
        .padding(.top, 8)
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    // MARK: - Opening Hours Section
    private var openingHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(R.string.localizable.availabilityOpeningHours())
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button {
                    viewModel.showEditHours = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.openingHours, id: \.day) { hours in
                    OpeningHoursRow(hours: hours)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .sheet(isPresented: $viewModel.showEditHours) {
            EditOpeningHoursView(
                hours: $viewModel.openingHours,
                onSave: { newHours in
                    Task {
                        await viewModel.saveOpeningHours(newHours)
                    }
                }
            )
        }
    }
    
    // MARK: - Blocked Slots Section
    private var blockedSlotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(R.string.localizable.availabilityBlockedSlots())
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button {
                    viewModel.showBlockSlot = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text(R.string.localizable.availabilityBlockSlot())
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .clipShape(Capsule())
                }
            }
            
            if viewModel.blockedSlots.isEmpty {
                Text(R.string.localizable.availabilityNoBlockedSlots())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.blockedSlots) { slot in
                    BlockedSlotRow(slot: slot) {
                        Task {
                            await viewModel.unblockSlot(slot.id)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .sheet(isPresented: $viewModel.showBlockSlot) {
            BlockSlotView { date, time in
                Task {
                    await viewModel.blockSlot(date: date, time: time)
                }
            }
        }
    }
}

// MARK: - Helper Views
private struct StatBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(count) \(label)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

private struct BookingQuickCard: View {
    let booking: Booking
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.displayServiceName)
                    .font(.system(size: 15, weight: .semibold))
                
                if let time = booking.startTime {
                    Text(time)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(String(format: "%.0f €", booking.price))
                .font(.system(size: 15, weight: .bold))
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .pending: return .orange
        case .confirmed, .started, .inProgress: return .green
        case .declined, .cancelled: return .red
        case .completed: return .blue
        }
    }
}

// MARK: - Opening Hours Row
private struct OpeningHoursRow: View {
    let hours: OpeningHours
    
    var body: some View {
        HStack {
            Text(hours.dayName)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 100, alignment: .leading)
            
            if hours.isClosed {
                Text(R.string.localizable.availabilityClosed())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                Text("\(hours.startTime) - \(hours.endTime)")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Blocked Slot Row
private struct BlockedSlotRow: View {
    let slot: BlockedSlot
    let onUnblock: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(slot.date)
                    .font(.system(size: 15, weight: .medium))
                Text(slot.time)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                onUnblock()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - ViewModel
@MainActor
final class ProviderAvailabilityViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var openingHours: [OpeningHours] = []
    @Published var blockedSlots: [BlockedSlot] = []
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var showEditHours = false
    @Published var showBlockSlot = false
    @Published var errorMessage: String?
    
    // Calendar Sync
    @Published var isCalendarSyncEnabled = false
    @Published var calendarSyncStatus: EKAuthorizationStatus = .notDetermined
    @Published var syncedBookingsCount: Int?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        loadDefaultOpeningHours()
        checkCalendarAuthorization()
    }
    
    private func checkCalendarAuthorization() {
        calendarSyncStatus = engine.calendarService.getAuthorizationStatus()
        // Charger la préférence utilisateur depuis UserDefaults
        isCalendarSyncEnabled = UserDefaults.standard.bool(forKey: "calendarSyncEnabled")
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Nettoyer les bookings expirés (>6h pending) avant de charger
        _ = await engine.bookingService.cleanupExpiredBookings()
        
        // Load bookings for calendar
        let bookingsResult = await engine.bookingService.getBookings(scope: "provider", status: nil)
        if case .success(let bookings) = bookingsResult {
            self.bookings = bookings
            
            // Synchroniser avec le calendrier si activé
            if isCalendarSyncEnabled && calendarSyncStatus == .authorized {
                await syncBookingsToCalendar(bookings)
            }
        } else {
            self.bookings = []
        }
        
        // Load opening hours (mock pour l'instant - à remplacer par vraies données backend)
        // loadOpeningHours()
        
        // Load blocked slots (mock pour l'instant - à remplacer par vraies données backend)
        // loadBlockedSlots()
    }
    
    func toggleCalendarSync(enabled: Bool) async {
        isCalendarSyncEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "calendarSyncEnabled")
        
        if enabled {
            // Demander l'autorisation si nécessaire
            let authorized = await engine.calendarService.requestAuthorization()
            calendarSyncStatus = engine.calendarService.getAuthorizationStatus()
            
            if authorized {
                // Synchroniser toutes les réservations
                await syncBookingsToCalendar(bookings)
            } else {
                isCalendarSyncEnabled = false
                UserDefaults.standard.set(false, forKey: "calendarSyncEnabled")
            }
        } else {
            // Désactiver la synchronisation (ne supprime pas les événements existants)
            syncedBookingsCount = nil
        }
    }
    
    private func syncBookingsToCalendar(_ bookings: [Booking]) async {
        let result = await engine.calendarService.syncAllBookings(bookings)
        switch result {
        case .success(let count):
            syncedBookingsCount = count
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func calendarStatus(forMonth month: Date) -> CalendarDayStatus {
        let calendar = Calendar.current
        let target = calendar.dateComponents([.year, .month], from: month)
        
        var confirmed = Set<Int>()
        var pending = Set<Int>()
        var cancelled = Set<Int>()
        
        for booking in bookings {
            // Exclure les réservations expirées du calendrier
            if booking.isExpired {
                continue
            }
            
            guard let date = DateFormatters.isoDate(booking.date) else { continue }
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            
            guard comps.year == target.year,
                  comps.month == target.month,
                  let day = comps.day else { continue }
            
            switch booking.status {
            case .confirmed, .started, .inProgress:
                confirmed.insert(day)
            case .pending:
                pending.insert(day)
            case .declined, .cancelled, .completed:
                cancelled.insert(day)
            }
        }
        
        return CalendarDayStatus(
            confirmed: confirmed,
            pending: pending,
            cancelled: cancelled
        )
    }
    
    // MARK: - Pending bookings helpers
    func pendingBookings(for date: Date) -> [Booking] {
        let dateString = DateFormatters.onlyDate(date)
        return bookings
            .filter { $0.date == dateString }
            .filter { $0.status == .pending }
            .filter { !$0.isExpired } // Exclure les réservations expirées (>6h)
            .sorted { ($0.startTime ?? "00:00") < ($1.startTime ?? "00:00") }
    }
    
    func confirmBooking(_ id: String) async {
        print("🟢 [ProviderAvailabilityVM] confirmBooking START - id: \(id)")
        defer { print("🟢 [ProviderAvailabilityVM] confirmBooking END") }
        
        print("🟢 [ProviderAvailabilityVM] confirmBooking - Calling bookingService.confirmBooking...")
        let res = await engine.bookingService.confirmBooking(id: id)
        print("🟢 [ProviderAvailabilityVM] confirmBooking - bookingService.confirmBooking returned")
        
        switch res {
        case .success(let success):
            print("✅ [ProviderAvailabilityVM] confirmBooking - Success: \(success)")
            if let idx = bookings.firstIndex(where: { $0.id == id }) {
                print("🟢 [ProviderAvailabilityVM] confirmBooking - Found booking at index \(idx)")
                var updated = bookings[idx]
                updated.status = .confirmed
                bookings[idx] = updated
                print("✅ [ProviderAvailabilityVM] confirmBooking - Booking status updated to confirmed")
                
                // Analytics: Booking confirmed
                FirebaseManager.shared.logEvent(
                    FirebaseManager.Event.bookingConfirmed,
                    parameters: [
                        "booking_id": updated.id,
                        "provider_id": updated.providerId,
                        "price": updated.price
                    ]
                )
                
                // Notification pour le customer
                NotificationsManager.shared.notifyBookingConfirmed(
                    bookingId: updated.id,
                    providerName: updated.displayProviderName,
                    date: updated.date
                )
            } else {
                print("⚠️ [ProviderAvailabilityVM] confirmBooking - Booking not found in local array")
            }
        case .failure(let err):
            print("❌ [ProviderAvailabilityVM] confirmBooking - Error: \(err.localizedDescription)")
            errorMessage = err.localizedDescription
        }
    }
    
    func declineBooking(_ id: String) async {
        print("🟢 [ProviderAvailabilityVM] declineBooking START - id: \(id)")
        defer { print("🟢 [ProviderAvailabilityVM] declineBooking END") }
        
        print("🟢 [ProviderAvailabilityVM] declineBooking - Calling bookingService.declineBooking...")
        let res = await engine.bookingService.declineBooking(id: id)
        print("🟢 [ProviderAvailabilityVM] declineBooking - bookingService.declineBooking returned")
        
        switch res {
        case .success(let success):
            print("✅ [ProviderAvailabilityVM] declineBooking - Success: \(success)")
            if let idx = bookings.firstIndex(where: { $0.id == id }) {
                print("🟢 [ProviderAvailabilityVM] declineBooking - Found booking at index \(idx)")
                var updated = bookings[idx]
                updated.status = .declined
                bookings[idx] = updated
                print("✅ [ProviderAvailabilityVM] declineBooking - Booking status updated to declined")
                // Notification pour le customer
                NotificationsManager.shared.notifyBookingDeclined(
                    bookingId: updated.id,
                    providerName: updated.displayProviderName
                )
            } else {
                print("⚠️ [ProviderAvailabilityVM] declineBooking - Booking not found in local array")
            }
        case .failure(let err):
            print("❌ [ProviderAvailabilityVM] declineBooking - Error: \(err.localizedDescription)")
            errorMessage = err.localizedDescription
        }
    }
    
    func saveOpeningHours(_ hours: [OpeningHours]) async {
        // TODO: Appel API pour sauvegarder les heures d'ouverture
        self.openingHours = hours
    }
    
    func blockSlot(date: String, time: String) async {
        // TODO: Appel API pour bloquer un créneau
        let newSlot = BlockedSlot(id: UUID().uuidString, date: date, time: time)
        blockedSlots.append(newSlot)
    }
    
    func unblockSlot(_ id: String) async {
        // TODO: Appel API pour débloquer un créneau
        blockedSlots.removeAll { $0.id == id }
    }
    
    private func loadDefaultOpeningHours() {
        openingHours = [
            OpeningHours(day: 1, dayName: R.string.localizable.availabilityMonday(), startTime: "09:00", endTime: "18:00", isClosed: false),
            OpeningHours(day: 2, dayName: R.string.localizable.availabilityTuesday(), startTime: "09:00", endTime: "18:00", isClosed: false),
            OpeningHours(day: 3, dayName: R.string.localizable.availabilityWednesday(), startTime: "09:00", endTime: "18:00", isClosed: false),
            OpeningHours(day: 4, dayName: R.string.localizable.availabilityThursday(), startTime: "09:00", endTime: "18:00", isClosed: false),
            OpeningHours(day: 5, dayName: R.string.localizable.availabilityFriday(), startTime: "09:00", endTime: "18:00", isClosed: false),
            OpeningHours(day: 6, dayName: R.string.localizable.availabilitySaturday(), startTime: "10:00", endTime: "16:00", isClosed: false),
            OpeningHours(day: 7, dayName: R.string.localizable.availabilitySunday(), startTime: "", endTime: "", isClosed: true)
        ]
    }
}

// MARK: - Models
struct OpeningHours: Identifiable {
    let id = UUID()
    let day: Int // 1 = Monday, 7 = Sunday
    let dayName: String
    var startTime: String
    var endTime: String
    var isClosed: Bool
}

struct BlockedSlot: Identifiable {
    let id: String
    let date: String
    let time: String
}

// MARK: - Edit Opening Hours View
struct EditOpeningHoursView: View {
    @Binding var hours: [OpeningHours]
    let onSave: ([OpeningHours]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($hours) { $hour in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(hour.dayName, isOn: Binding(
                            get: { !hour.isClosed },
                            set: { hour.isClosed = !$0 }
                        ))
                        
                        if !hour.isClosed {
                            HStack {
                                TextField("09:00", text: $hour.startTime)
                                    .keyboardType(.numbersAndPunctuation)
                                Text("-")
                                TextField("18:00", text: $hour.endTime)
                                    .keyboardType(.numbersAndPunctuation)
                            }
                        }
                    }
                }
            }
            .navigationTitle(R.string.localizable.availabilityEditHours())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(R.string.localizable.commonSave()) {
                        onSave(hours)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(R.string.localizable.commonCancel()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Block Slot View
struct BlockSlotView: View {
    let onBlock: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedTime = "09:00"
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    R.string.localizable.availabilitySelectDate(),
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                
                TextField(R.string.localizable.availabilitySelectTime(), text: $selectedTime)
                    .keyboardType(.numbersAndPunctuation)
            }
            .navigationTitle(R.string.localizable.availabilityBlockSlot())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(R.string.localizable.commonSave()) {
                        let dateString = DateFormatters.onlyDate(selectedDate)
                        onBlock(dateString, selectedTime)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(R.string.localizable.commonCancel()) {
                        dismiss()
                    }
                }
            }
        }
    }
}
