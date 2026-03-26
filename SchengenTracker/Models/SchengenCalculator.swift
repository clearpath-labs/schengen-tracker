import Foundation

struct SchengenCalculator {
    let trips: [Trip]
    private let cal = Calendar.current

    /// The 180-day window starts on `windowStartDate` and ends 179 days later.
    func windowEnd(from windowStartDate: Date) -> Date {
        let start = cal.startOfDay(for: windowStartDate)
        return cal.date(byAdding: .day, value: 179, to: start)!
    }

    /// Count days spent (or planned) in Schengen within the 180-day window
    /// starting on `windowStartDate`.
    func daysUsed(windowStartDate: Date) -> Int {
        let wStart = cal.startOfDay(for: windowStartDate)
        let wEnd = windowEnd(from: windowStartDate)

        var count = 0
        for trip in trips {
            let tripStart = cal.startOfDay(for: trip.startDate)
            let tripEnd = cal.startOfDay(for: trip.endDate)

            let effectiveStart = max(tripStart, wStart)
            let effectiveEnd = min(tripEnd, wEnd)

            if effectiveStart <= effectiveEnd {
                count += cal.dateComponents([.day], from: effectiveStart, to: effectiveEnd).day! + 1
            }
        }
        return count
    }

    /// Days remaining out of 90 within the window.
    func daysRemaining(windowStartDate: Date) -> Int {
        max(0, 90 - daysUsed(windowStartDate: windowStartDate))
    }

    /// Whether a given date falls within any trip.
    func isInSchengen(on date: Date) -> Bool {
        let d = cal.startOfDay(for: date)
        return trips.contains { trip in
            let s = cal.startOfDay(for: trip.startDate)
            let e = cal.startOfDay(for: trip.endDate)
            return d >= s && d <= e
        }
    }

    /// Which trip (if any) covers the given date.
    func trip(on date: Date) -> Trip? {
        let d = cal.startOfDay(for: date)
        return trips.first { trip in
            let s = cal.startOfDay(for: trip.startDate)
            let e = cal.startOfDay(for: trip.endDate)
            return d >= s && d <= e
        }
    }

    /// Maximum consecutive days you can add starting from today, given the window.
    func maxStay(from today: Date, windowStartDate: Date) -> Int {
        let wEnd = windowEnd(from: windowStartDate)
        let todayStart = cal.startOfDay(for: today)

        if todayStart > wEnd { return 90 }

        let used = daysUsed(windowStartDate: windowStartDate)
        return max(0, 90 - used)
    }
}
