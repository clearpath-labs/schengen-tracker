import SwiftUI

/// A date picker that expands to show a graphical calendar with a
/// "Today" button inside the calendar area.
struct DatePickerWithToday: View {
    let label: String
    @Binding var date: Date
    @State private var isExpanded = false
    @State private var pickerID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed row — tap to toggle
            Button {
                isExpanded.toggle()
            } label: {
                HStack {
                    Text(label)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(date, style: .date)
                        .foregroundColor(.accentColor)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded graphical picker with Today button
            if isExpanded {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Today") {
                            date = Calendar.current.startOfDay(for: Date())
                            pickerID = UUID()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .id(pickerID)
                        .transition(.identity)
                }
                .transition(.identity)
            }
        }
        .animation(.none, value: isExpanded)
        .animation(.none, value: pickerID)
        .onChange(of: date) { _, _ in
            isExpanded = false
        }
    }
}
