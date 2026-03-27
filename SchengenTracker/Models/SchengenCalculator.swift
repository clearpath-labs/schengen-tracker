import Foundation

struct SchengenCalculator {
    let trips: [Trip]
    private let cal = Calendar.current

    // Pre-computed lookup: date -> Trip (built once per init)
    private let dateTripMap: [Date: Trip]

    init(trips: [Trip]) {
        self.trips = trips
        var map: [Date: Trip] = [:]
        let cal = Calendar.current
        for trip in trips {
            let start = cal.startOfDay(for: trip.startDate)
            let end = cal.startOfDay(for: trip.endDate)
            var d = start
            while d <= end {
                map[d] = trip
                d = cal.date(byAdding: .day, value: 1, to: d)!
            }
        }
        self.dateTripMap = map
    }

    /// The 180-day window starts on `windowStartDate` and ends 179 days later.
    func windowEnd(from windowStartDate: Date) -> Date {
        let start = cal.startOfDay(for: windowStartDate)
        return cal.date(byAdding: .day, value: 179, to: start)!
    }

    /// Count days spent (or planned) in Schengen within the 180-day window.
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

    /// Whether a given date falls within any trip (O(1) lookup).
    func isInSchengen(on date: Date) -> Bool {
        dateTripMap[cal.startOfDay(for: date)] != nil
    }

    /// Which trip (if any) covers the given date (O(1) lookup).
    func trip(on date: Date) -> Trip? {
        dateTripMap[cal.startOfDay(for: date)]
    }
}
