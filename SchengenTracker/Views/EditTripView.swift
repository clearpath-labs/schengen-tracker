import SwiftUI

struct EditTripView: View {
    @EnvironmentObject var store: TripStore
    @Environment(\.dismiss) private var dismiss

    let trip: Trip

    @State private var selectionMode: LabelMode
    @State private var selectedCountry: SchengenCountry?
    @State private var customLabel: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showError = false

    enum LabelMode: String, CaseIterable {
        case country = "Country"
        case custom = "Custom"
    }

    init(trip: Trip) {
        self.trip = trip
        if trip.country != nil {
            _selectionMode = State(initialValue: .country)
            _selectedCountry = State(initialValue: trip.country)
            _customLabel = State(initialValue: "")
        } else {
            _selectionMode = State(initialValue: trip.label.isEmpty ? .country : .custom)
            _selectedCountry = State(initialValue: nil)
            _customLabel = State(initialValue: trip.label)
        }
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Label (Optional)") {
                    Picker("Type", selection: $selectionMode) {
                        ForEach(LabelMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if selectionMode == .country {
                        Picker("Country", selection: $selectedCountry) {
                            Text("None").tag(SchengenCountry?.none)
                            ForEach(schengenCountries) { country in
                                Text(country.display).tag(SchengenCountry?.some(country))
                            }
                        }
                    } else {
                        TextField("Custom label", text: $customLabel)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section("Dates") {
                    DatePickerWithToday(label: "Entry Date", date: $startDate)
                    DatePickerWithToday(label: "Exit Date", date: $endDate)
                }

                if showError {
                    Section {
                        Text("Exit date must be on or after entry date.")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Delete Trip", role: .destructive) {
                        store.deleteTrip(trip)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let cal = Calendar.current
                        let s = cal.startOfDay(for: startDate)
                        let e = cal.startOfDay(for: endDate)

                        if s > e {
                            showError = true
                            return
                        }

                        var updated = trip
                        updated.label = selectionMode == .custom ? customLabel.trimmingCharacters(in: .whitespaces) : ""
                        updated.country = selectionMode == .country ? selectedCountry : nil
                        updated.startDate = s
                        updated.endDate = e
                        store.updateTrip(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: startDate) { _, newStart in
                if endDate < newStart {
                    endDate = newStart
                }
            }
        }
    }
}

#Preview {
    EditTripView(trip: Trip(startDate: Date(), endDate: Date()))
        .environmentObject(TripStore())
}
