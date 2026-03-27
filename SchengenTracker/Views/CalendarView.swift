import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: TripStore
    @State private var displayedMonth: Date = Date()
    @State private var dragStartDay: Int? = nil
    @State private var dragEndDay: Int? = nil
    @State private var showingAddTrip = false

    private let cal = Calendar.current
    private let cellSize: CGFloat = 36

    private var calculator: SchengenCalculator {
        SchengenCalculator(trips: store.trips)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var firstWeekday: Int {
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = cal.date(from: comps)!
        return cal.component(.weekday, from: firstOfMonth) - 1
    }

    private var numberOfDays: Int {
        cal.range(of: .day, in: .month, for: displayedMonth)!.count
    }

    private var rows: [[Int?]] {
        var cells: [Int?] = Array(repeating: nil, count: firstWeekday)
        for d in 1...numberOfDays { cells.append(d) }
        while cells.count % 7 != 0 { cells.append(nil) }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0+7]) }
    }

    private func dateFor(day: Int) -> Date {
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        return cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day))!
    }

    private var selectedDayRange: (start: Int, end: Int)? {
        guard let s = dragStartDay, let e = dragEndDay else { return nil }
        return s <= e ? (s, e) : (e, s)
    }

    var body: some View {
        let calc = calculator
        let today = cal.startOfDay(for: Date())
        let wStart = cal.startOfDay(for: store.windowStartDate)
        let wEnd = cal.date(byAdding: .day, value: 179, to: wStart)!

        VStack(spacing: 10) {
            // Month navigation
            HStack {
                Button {
                    displayedMonth = cal.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left").fontWeight(.semibold)
                }
                Spacer()
                Text(monthTitle).font(.headline)
                Spacer()
                Button {
                    displayedMonth = cal.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right").fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 4)

            // Day-of-week headers
            let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(dayLetters[i])
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let currentRows = rows
            VStack(spacing: 2) {
                ForEach(0..<currentRows.count, id: \.self) { rowIdx in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { colIdx in
                            let day = currentRows[rowIdx][colIdx]
                            calendarCell(day: day, calc: calc, today: today, wStart: wStart, wEnd: wEnd)
                        }
                    }
                }
            }
            .gesture(dragGesture(rows: currentRows))

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
            dragStartDay = nil
            dragEndDay = nil
        }) {
            if let range = selectedDayRange {
                AddTripView(
                    initialStartDate: dateFor(day: range.start),
                    initialEndDate: dateFor(day: range.end)
                )
            }
        }
    }

    // MARK: - Cell

    @ViewBuilder
    private func calendarCell(day: Int?, calc: SchengenCalculator, today: Date, wStart: Date, wEnd: Date) -> some View {
        if let day {
            let date = dateFor(day: day)
            let d = cal.startOfDay(for: date)
            let isToday = d == today
            let trip = calc.trip(on: date)
            let inSchengen = trip != nil
            let isInWindow = d >= wStart && d <= wEnd
            let isSelected = isDayInSelectedRange(day)

            Text("\(day)")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .frame(maxWidth: .infinity)
                .frame(height: cellSize)
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
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: cellSize)
        }
    }

    // MARK: - Drag gesture (row/col math instead of GeometryReader)

    private func dragGesture(rows: [[Int?]]) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStartDay == nil {
                    dragStartDay = dayFromPoint(value.startLocation, rows: rows)
                }
                if let d = dayFromPoint(value.location, rows: rows) {
                    dragEndDay = d
                }
            }
            .onEnded { _ in
                if selectedDayRange != nil {
                    showingAddTrip = true
                } else {
                    dragStartDay = nil
                    dragEndDay = nil
                }
            }
    }

    private func dayFromPoint(_ pt: CGPoint, rows: [[Int?]]) -> Int? {
        // Grid starts after header area; estimate cell positions from grid dimensions
        let totalRows = rows.count
        let gridHeight = CGFloat(totalRows) * (cellSize + 2) - 2
        let gridWidth = UIScreen.main.bounds.width - 72 // padding: 16+16 parent + 16+16 card + 8 extra

        guard pt.y >= 0, pt.y < gridHeight, pt.x >= 0, pt.x < gridWidth else { return nil }

        let col = Int(pt.x / (gridWidth / 7))
        let row = Int(pt.y / (cellSize + 2))

        guard row < totalRows, col < 7 else { return nil }
        return rows[row][col]
    }

    private func isDayInSelectedRange(_ day: Int) -> Bool {
        guard let range = selectedDayRange else { return false }
        return day >= range.start && day <= range.end
    }

    private func tripColor(for trip: Trip?) -> Color {
        guard let trip else { return .clear }
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
}
