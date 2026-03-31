import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TripStore
    @State private var showingAddTrip = false

    var body: some View {
        let calculator = SchengenCalculator(trips: store.trips)

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    StatusCardView(calculator: calculator)

                    CalendarView()

                    BannerAdContainer(adUnitID: AdConfig.bannerAdUnitID)

                    TripListView(calculator: calculator)

                    // Dark mode toggle
                    HStack {
                        Label("Dark Mode", systemImage: store.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Toggle("", isOn: $store.isDarkMode)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Schengen Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TripStore())
}
