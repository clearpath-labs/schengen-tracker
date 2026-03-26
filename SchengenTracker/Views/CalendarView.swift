import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: TripStore
    @State private var displayedMonth: Date = Date()
    @State private var dragStartIndex: Int? = nil
    @State private var dragEndIndex: Int? = nil
    @State private var showingAddTrip = false
    @State private var cellFrames: [Int: CGRect] = [:]

    private let cal = Calendar.current

    private var calculator: SchengenCalculator {
        SchengenCalculator(trips: store.trips)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    /// First weekday of the month (0=Sunday)
    private var firstWeekday: Int {
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = cal.date(from: comps)!
        return cal.component(.weekday, from: firstOfMonth) - 1
    }

    /// Number of days in the month
    private var numberOfDays: Int {
        cal.range(of: .day, in: .month, for: displayedMonth)!.count
    }

    /// Total cells needed (blanks + days), rounded up to full weeks
    private var totalCells: Int {
        let raw = firstWeekday + numberOfDays
        return raw + (7 - raw % 7) % 7
    }

    /// Rows of 7 cells. Each cell is nil (blank) or a day number (1-based)
    private var rows: [[Int?]] {
        var cells: [Int?] = []
        for i in 0..<totalCells {
            let dayIndex = i - firstWeekday
            if dayIndex >= 0 && dayIndex < numberOfDays {
                cells.append(dayIndex + 1)
            } else {
                cells.append(nil)
            }
        }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<min($0 + 7, cells.count)]) }
    }

    /// Date for a given day number
    private func dateFor(day: Int) -> Date {
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        return cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day))!
    }

    /// Flat index for a day (used for drag tracking)
    private func flatIndex(day: Int) -> Int {
        firstWeekday + day - 1
    }

    /// Day from flat index
    private func dayFromFlatIndex(_ idx: Int) -> Int? {
        let d = idx - firstWeekday + 1
        return (d >= 1 && d <= numberOfDays) ? d : nil
    }

    /// Selected range as start/end days (normalized)
    private var selectedDayRange: (start: Int, end: Int)? {
        guard let si = dragStartIndex, let ei = dragEndIndex,
              let sd = dayFromFlatIndex(si), let ed = dayFromFlatIndex(ei) else { return nil }
        return sd <= ed ? (sd, ed) : (ed, sd)
    }

    private func isDayInSelectedRange(_ day: Int) -> Bool {
        guard let range = selectedDayRange else { return false }
        return day >= range.start && day <= range.end
    }

    var body: some View {
        VStack(spacing: 10) {
            // Month navigation
            HStack {
                Button {
                    displayedMonth = cal.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(monthTitle)
                    .font(.headline)

                Spacer()

                Button {
                    displayedMonth = cal.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 4)

            // Day-of-week headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { name in
                    Text(String(name.prefix(1)))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar rows
            VStack(spacing: 2) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { colIdx in
                            let cellIndex = rowIdx * 7 + colIdx
                            let day = row.count > colIdx ? row[colIdx] : nil

                            if let day = day {
                                let date = dateFor(day: day)
                                let isToday = cal.isDateInToday(date)
                                let inSchengen = calculator.isInSchengen(on: date)
                                let trip = calculator.trip(on: date)
                                let isInWindow = isDateInWindow(date)
                                let isSelected = isDayInSelectedRange(day)

                                Text("\(day)")
                                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background {
                                        if isSelected {
                                            Circle().fill(Color.accentColor)
                                        } else if inSchengen {
                                            Circle().fill(tripColor(for: trip).opacity(0.25))
                                        } else if isInWindow {
                                            Circle().fill(Color(.systemGray5))
                                        }
                                    }
                                    .foregroundColor(
                                        isSelected ? .white :
                                        isToday ? .accentColor :
                                        isInWindow ? .primary : Color(.tertiaryLabel)
                                    )
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: CellFrameKey.self,
                                                value: [cellIndex: geo.frame(in: .named("grid"))]
                                            )
                                        }
                                    )
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                            }
                        }
                    }
                }
            }
            .coordinateSpace(name: "grid")
            .onPreferenceChange(CellFrameKey.self) { cellFrames = $0 }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("grid"))
                    .onChanged { value in
                        if dragStartIndex == nil {
                            dragStartIndex = cellIndexFromLocation(value.startLocation)
                        }
                        if let idx = cellIndexFromLocation(value.location) {
                            dragEndIndex = idx
                        }
                    }
                    .onEnded { _ in
                        if selectedDayRange != nil {
                            showingAddTrip = true
                        } else {
                            dragStartIndex = nil
                            dragEndIndex = nil
                        }
                    }
            )

            // Legend
            HStack(spacing: 16) {
                legendDot(color: .orange.opacity(0.25), label: "Past")
                legendDot(color: .green.opacity(0.25), label: "Current")
                legendDot(color: .blue.opacity(0.25), label: "Planned")
            }
            .font(.caption2)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .onChange(of: store.windowStartDate) { _, newDate in
            displayedMonth = newDate
        }
        .sheet(isPresented: $showingAddTrip, onDismiss: {
            dragStartIndex = nil
            dragEndIndex = nil
        }) {
            if let range = selectedDayRange {
                AddTripView(
                    initialStartDate: dateFor(day: range.start),
                    initialEndDate: dateFor(day: range.end)
                )
            }
        }
    }

    // MARK: - Helpers

    private func isDateInWindow(_ date: Date) -> Bool {
        let d = cal.startOfDay(for: date)
        let wStart = cal.startOfDay(for: store.windowStartDate)
        let wEnd = cal.date(byAdding: .day, value: 179, to: wStart)!
        return d >= wStart && d <= wEnd
    }

    private func tripColor(for trip: Trip?) -> Color {
        guard let trip = trip else { return .clear }
        switch trip.status(on: Date()) {
        case .past: return .orange
        case .current: return .green
        case .future: return .blue
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).foregroundStyle(.secondary)
        }
    }

    private func cellIndexFromLocation(_ pt: CGPoint) -> Int? {
        for (idx, frame) in cellFrames where frame.contains(pt) {
            if dayFromFlatIndex(idx) != nil { return idx }
        }
        return nil
    }
}

// PreferenceKey for cell hit-testing
struct CellFrameKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
