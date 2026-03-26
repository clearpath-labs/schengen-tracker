import SwiftUI

struct AddTripView: View {
    @EnvironmentObject var store: TripStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectionMode: LabelMode = .country
    @State private var selectedCountry: SchengenCountry? = nil
    @State private var customLabel = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showError = false

    enum LabelMode: String, CaseIterable {
        case country = "Country"
        case custom = "Custom"
    }

    init(initialStartDate: Date = Date(), initialEndDate: Date = Date()) {
        _startDate = State(initialValue: initialStartDate)
        _endDate = State(initialValue: initialEndDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Label selection
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
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let cal = Calendar.current
                        let s = cal.startOfDay(for: startDate)
                        let e = cal.startOfDay(for: endDate)

                        if s > e {
                            showError = true
                            return
                        }

                        let label = selectionMode == .custom ? customLabel.trimmingCharacters(in: .whitespaces) : ""
                        let country = selectionMode == .country ? selectedCountry : nil

                        let trip = Trip(label: label, country: country, startDate: s, endDate: e)
                        store.addTrip(trip)
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
    AddTripView()
        .environmentObject(TripStore())
}
