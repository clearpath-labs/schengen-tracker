import Foundation

struct Trip: Identifiable, Codable, Equatable {
    var id: UUID
    var label: String
    var country: SchengenCountry?
    var startDate: Date
    var endDate: Date

    init(id: UUID = UUID(), label: String = "", country: SchengenCountry? = nil, startDate: Date, endDate: Date) {
        self.id = id
        self.label = label
        self.country = country
        self.startDate = startDate
        self.endDate = endDate
    }

    var dayCount: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
    }

    /// Display label: country display if set, otherwise custom label
    var displayLabel: String {
        if let country = country {
            return country.display
        }
        return label
    }

    func status(on today: Date) -> TripStatus {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: today)
        let tripStart = cal.startOfDay(for: startDate)
        let tripEnd = cal.startOfDay(for: endDate)

        if todayStart > tripEnd { return .past }
        if todayStart < tripStart { return .future }
        return .current
    }

    /// Check if a given date falls within this trip
    func containsDate(_ date: Date) -> Bool {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        let s = cal.startOfDay(for: startDate)
        let e = cal.startOfDay(for: endDate)
        return d >= s && d <= e
    }
}

enum TripStatus: String {
    case past = "Past"
    case current = "Current"
    case future = "Planned"
}
