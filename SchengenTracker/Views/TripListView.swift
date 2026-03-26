import SwiftUI

struct TripListView: View {
    @EnvironmentObject var store: TripStore
    let calculator: SchengenCalculator

    @State private var editingTrip: Trip?

    private var grouped: (past: [Trip], current: [Trip], future: [Trip]) {
        store.tripsByStatus(on: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Trips")
                .font(.title3)
                .fontWeight(.semibold)

            if store.trips.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "airplane")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Text("No trips added yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Tap + to add your first trip")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                let g = grouped

                if !g.current.isEmpty {
                    TripSectionView(title: "Current", trips: g.current, color: .green, onEdit: { editingTrip = $0 })
                }

                if !g.future.isEmpty {
                    TripSectionView(title: "Planned", trips: g.future, color: .blue, onEdit: { editingTrip = $0 })
                }

                if !g.past.isEmpty {
                    TripSectionView(title: "Past", trips: g.past, color: .orange, onEdit: { editingTrip = $0 })
                }
            }

            // Info box
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)

                Text("The Schengen 90/180 rule allows a maximum of **90 days** within any **180-day** window. Both entry and exit dates count as days present.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(20)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .sheet(item: $editingTrip) { trip in
            EditTripView(trip: trip)
        }
    }
}

// MARK: - Trip Section

struct TripSectionView: View {
    let title: String
    let trips: [Trip]
    let color: Color
    let onEdit: (Trip) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .textCase(.uppercase)
                .padding(.leading, 4)

            ForEach(trips) { trip in
                TripRowView(trip: trip, statusColor: color)
                    .onTapGesture { onEdit(trip) }
            }
        }
    }
}

// MARK: - Trip Row

struct TripRowView: View {
    @EnvironmentObject var store: TripStore
    let trip: Trip
    let statusColor: Color

    private var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: trip.startDate)) — \(formatter.string(from: trip.endDate))"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Dates and label
            VStack(alignment: .leading, spacing: 2) {
                Text(dateRange)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !trip.displayLabel.isEmpty {
                    Text(trip.displayLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Day count
            Text("\(trip.dayCount)d")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            // Delete
            Button {
                withAnimation {
                    store.deleteTrip(trip)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
