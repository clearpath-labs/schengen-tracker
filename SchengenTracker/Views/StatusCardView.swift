import SwiftUI

struct StatusCardView: View {
    @EnvironmentObject var store: TripStore
    let calculator: SchengenCalculator
    @State private var showDatePicker = false
    @State private var pickerID = UUID()

    private var daysUsed: Int { calculator.daysUsed(windowStartDate: store.windowStartDate) }
    private var daysRemaining: Int { calculator.daysRemaining(windowStartDate: store.windowStartDate) }
    private var percentage: Double { Double(daysUsed) / 90.0 }

    private var themeColor: Color {
        if daysRemaining <= 7 { return .red }
        if daysRemaining <= 29 { return .orange }
        return .primary
    }

    private var barColor: Color {
        if daysRemaining <= 7 { return .red }
        if daysRemaining <= 29 { return .orange }
        return .green
    }

    private var windowDateRange: String {
        let wEnd = calculator.windowEnd(from: store.windowStartDate)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: store.windowStartDate)) — \(formatter.string(from: wEnd))"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Window start date picker
            VStack(spacing: 8) {
                HStack {
                    Text("Window starts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        Text(store.windowStartDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                }

                if showDatePicker {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button("Today") {
                                store.windowStartDate = Calendar.current.startOfDay(for: Date())
                                pickerID = UUID()
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                        }
                        .padding(.bottom, 4)

                        DatePicker("", selection: $store.windowStartDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .id(pickerID)
                            .transition(.identity)
                    }
                }
            }

            Divider()

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor)
                            .frame(width: geo.size.width * min(CGFloat(percentage), 1.0), height: 12)
                            .animation(.easeInOut(duration: 0.4), value: daysUsed)
                    }
                }
                .frame(height: 12)

                Text("180-day window: \(windowDateRange)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Stats
            HStack(spacing: 12) {
                StatBox(value: "\(daysUsed)", label: "Days Used", color: themeColor)
                StatBox(value: "\(daysRemaining)", label: "Days Remaining", color: themeColor)
            }
        }
        .padding(20)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

private struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
