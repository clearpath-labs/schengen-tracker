import Foundation
import SwiftUI

@MainActor
class TripStore: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet { saveTrips() }
    }

    @Published var windowStartDate: Date {
        didSet { saveWindowStart() }
    }

    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: darkModeKey) }
    }

    private let tripsKey = "schengen_trips"
    private let windowStartKey = "schengen_window_start"
    private let darkModeKey = "schengen_dark_mode"

    init() {
        if let saved = UserDefaults.standard.object(forKey: windowStartKey) as? Date {
            self.windowStartDate = saved
        } else {
            self.windowStartDate = Calendar.current.startOfDay(for: Date())
        }
        self.isDarkMode = UserDefaults.standard.bool(forKey: darkModeKey)
        loadTrips()
    }

    func addTrip(_ trip: Trip) {
        trips.append(trip)
    }

    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
    }

    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        }
    }

    var sortedTrips: [Trip] {
        trips.sorted { $0.startDate < $1.startDate }
    }

    func tripsByStatus(on today: Date) -> (past: [Trip], current: [Trip], future: [Trip]) {
        let sorted = sortedTrips
        let past = sorted.filter { $0.status(on: today) == .past }
        let current = sorted.filter { $0.status(on: today) == .current }
        let future = sorted.filter { $0.status(on: today) == .future }
        return (past, current, future)
    }

    // MARK: - Persistence

    private func saveTrips() {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }

    private func loadTrips() {
        guard let data = UserDefaults.standard.data(forKey: tripsKey),
              let decoded = try? JSONDecoder().decode([Trip].self, from: data) else { return }
        trips = decoded
    }

    private func saveWindowStart() {
        UserDefaults.standard.set(windowStartDate, forKey: windowStartKey)
    }
}
