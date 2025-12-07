import SwiftUI

struct ProviderMonthCalendarView: View {
    @Binding var selectedDate: Date
    let status: CalendarDayStatus// jours du mois avec réservations
    private let calendar = Calendar.current
    var body: some View {
        VStack(spacing: 12) {
            header
            weekdayRow
            monthGrid
        }
        .padding(.horizontal, 20)
    }
    // MARK: - Header (mois + flèches)
    private var header: some View {
        HStack {
            Text(monthTitle(for: selectedDate))
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
    
    // MARK: - Row des jours MON TUE WED...
    private var weekdayRow: some View {
        let symbols = weekdaySymbols()
        
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Grille du mois
    private var monthGrid: some View {
        let days = makeDaysForMonth()
        let chunks = days.chunked(into: 7)
        
        return VStack(spacing: 8) {
            ForEach(0..<chunks.count, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(chunks[rowIndex], id: \.self) { day in
                        dayCell(day)
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
        }
    }
    
    // MARK: - Cellule d’un jour
    private func dayCell(_ day: Int?) -> some View {
        guard let day = day else {
            return AnyView(Color.clear.frame(height: 40))
        }
        
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let date = calendar.date(from: DateComponents(
            year: comps.year,
            month: comps.month,
            day: day
        ))!
        
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        
        let isConfirmed = status.confirmed.contains(day)
        let isPending   = status.pending.contains(day)
        let isCancelled = status.cancelled.contains(day)
        
        return AnyView(
            Button { selectedDate = date } label: {
                ZStack {
                    
                    // ▶️ Sélection
                    if isSelected {
                        Circle()
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: 34, height: 34)
                    }
                    
                    // ▶️ Confirmed = GREEN
                    if isConfirmed {
                        Circle()
                            .fill(Color.green.opacity(0.20))
                            .overlay(
                                Circle().stroke(Color.green, lineWidth: 2)
                            )
                            .frame(width: 34, height: 34)
                    }
                    
                    // ▶️ Pending = ORANGE
                    if isPending {
                        Circle()
                            .fill(Color.orange.opacity(0.20))
                            .overlay(
                                Circle().stroke(Color.orange, lineWidth: 2)
                            )
                            .frame(width: 34, height: 34)
                    }
                    
                    // ▶️ Cancelled/Declined/Completed = RED
                    if isCancelled {
                        Circle()
                            .fill(Color.red.opacity(0.20))
                            .overlay(
                                Circle().stroke(Color.red, lineWidth: 2)
                            )
                            .frame(width: 34, height: 34)
                    }
                    
                    Text("\(day)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                }
                .frame(height: 40)
            }
                .buttonStyle(.plain)
        )
    }
    
    // MARK: - Helpers Date
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            // garder le même jour si possible
            selectedDate = newDate
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .calendarMonthChanged, object: nil)
            }
        }
    }
    
    private func weekdaySymbols() -> [String] {
        var symbols = calendar.shortWeekdaySymbols   // ["Sun", "Mon", ...]
        let firstWeekdayIndex = calendar.firstWeekday - 1
        if firstWeekdayIndex > 0 {
            let head = symbols[firstWeekdayIndex...]
            let tail = symbols[..<firstWeekdayIndex]
            symbols = Array(head + tail)
        }
        return symbols
    }
    
    /// Retourne un tableau d’Int? représentant le mois, avec des `nil` pour les cases vides
    private func makeDaysForMonth() -> [Int?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return [] }
        
        let numDays = range.count
        
        let weekdayFirst = calendar.component(.weekday, from: firstOfMonth)
        let firstWeekday = calendar.firstWeekday
        let leadingEmpty = (weekdayFirst - firstWeekday + 7) % 7
        
        var days: [Int?] = Array(repeating: nil, count: leadingEmpty)
        days += range.map { Optional($0) }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
}

// petit helper pour découper le tableau en semaines
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
