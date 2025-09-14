import SwiftUI
import OSLog

struct CalendarNavigationView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    @State private var showingMonthPicker = false

    var body: some View {
        HStack {
            // Previous month button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    calendarManager.previousMonth()
                    Logger.ui.logInfo("Previous month navigated", context: "CalendarNavigationView")
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5), in: Circle())
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.15), value: calendarManager.currentMonth)
            }
            .accessibilityLabel("Previous month")
            .accessibilityHint("Navigate to the previous month")

            Spacer()

            // Current month display with tap to pick
            Button(action: {
                showingMonthPicker = true
                Logger.ui.logInfo("Month picker opened", context: "CalendarNavigationView")
            }) {
                VStack(spacing: 2) {
                    Text(calendarManager.currentMonth.monthName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .animation(.easeInOut(duration: 0.3), value: calendarManager.currentMonth.monthName)

                    Text("Tap to change")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("Current month: \(calendarManager.currentMonth.monthName)")
            .accessibilityHint("Tap to select a different month")
            .sheet(isPresented: $showingMonthPicker) {
                MonthPickerView(calendarManager: calendarManager)
            }

            Spacer()

            // Next month button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    calendarManager.nextMonth()
                    Logger.ui.logInfo("Next month navigated", context: "CalendarNavigationView")
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5), in: Circle())
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.15), value: calendarManager.currentMonth)
            }
            .accessibilityLabel("Next month")
            .accessibilityHint("Navigate to the next month")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calendar navigation")
    }
}

struct MonthPickerView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear: Int
    @State private var selectedMonth: Int

    private let calendar = Calendar.current
    private let currentYear = Calendar.current.component(.year, from: Date())

    init(calendarManager: CalendarStateManager) {
        self.calendarManager = calendarManager
        self._selectedYear = State(initialValue: calendarManager.currentMonth.year)
        self._selectedMonth = State(initialValue: calendarManager.currentMonth.month)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Year picker
                yearPickerSection

                // Month picker
                monthPickerSection

                Spacer()
            }
            .padding(20)
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityHint("Cancel month selection")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applySelection()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .accessibilityHint("Confirm month selection")
                }
            }
            .onAppear {
                Logger.ui.logInfo("Month picker view appeared", context: "MonthPickerView")
            }
        }
    }

    // MARK: - View Components

    private var yearPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Year")
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Picker("Year", selection: $selectedYear) {
                ForEach(currentYear - 5...currentYear + 5, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .accessibilityLabel("Select year")
        }
    }

    private var monthPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Month")
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...12, id: \.self) { month in
                    monthButton(for: month)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Month selection grid")
        }
    }

    @ViewBuilder
    private func monthButton(for month: Int) -> some View {
        Button(action: {
            selectedMonth = month
            Logger.ui.logDebug("Selected month: \(monthName(for: month))", context: "MonthPickerView")
        }) {
            Text(monthName(for: month))
                .font(.body)
                .fontWeight(selectedMonth == month ? .bold : .regular)
                .foregroundStyle(selectedMonth == month ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selectedMonth == month ? .blue : Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .scaleEffect(selectedMonth == month ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: selectedMonth)
        }
        .accessibilityLabel(monthName(for: month))
        .accessibilityAddTraits(selectedMonth == month ? [.isSelected] : [])
    }

    // MARK: - Helper Methods

    private func monthName(for month: Int) -> String {
        let calendar = Calendar.current
        let components = DateComponents(year: 2000, month: month, day: 1)
        let date = calendar.date(from: components) ?? Date()
        return DateFormatter().monthSymbols[month - 1]
    }

    private func applySelection() {
        let calendar = Calendar.current
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        if let newDate = calendar.date(from: components) {
            let newMonth = CalendarMonth(date: newDate)
            withAnimation(.easeInOut(duration: 0.3)) {
                calendarManager.scrollToMonth(newMonth)
            }
            Logger.ui.logInfo("Month selected: \(monthName(for: selectedMonth)) \(selectedYear)", context: "MonthPickerView")
        }
    }
}

#Preview {
    CalendarNavigationView(calendarManager: CalendarStateManager())
}