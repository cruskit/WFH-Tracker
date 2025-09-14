import SwiftUI

struct WorkHoursEntryView: View {
    let date: Date
    let existingWorkDay: WorkDay?
    let existingWorkDays: [WorkDay]
    let onSave: ([WorkDay]) -> Void
    let onCancel: () -> Void

    @EnvironmentObject var diContainer: DIContainer
    @State private var weeklyEntries: [Date: WorkDayEntry] = [:]
    @State private var showingAdvancedEntry: Date?
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    @State private var isLoading = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView

                // Weekly Entry List
                if isLoading {
                    loadingView
                } else {
                    weeklyEntryList
                }

                Spacer()

                // Action Buttons
                actionButtons
            }
            .navigationTitle("Weekly Hours")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .accessibilityHint("Cancels entry and returns to calendar")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkDays()
                    }
                    .fontWeight(.semibold)
                    .accessibilityHint("Saves all entered work hours")
                }
            }
        }
        .alert("Invalid Input", isPresented: $showingValidationError) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .sheet(item: Binding<DateWrapper?>(
            get: { showingAdvancedEntry.map(DateWrapper.init) },
            set: { _ in showingAdvancedEntry = nil }
        )) { dateWrapper in
            advancedEntrySheet(for: dateWrapper.date)
        }
        .onAppear {
            loadExistingData()
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Week of \(weekStartDateString)")
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Text("Tap work types to quickly log hours, or use advanced entry for detailed tracking")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.3))
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var weeklyEntryList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    CompactDayEntryRow(
                        date: date,
                        entry: weeklyEntries[date] ?? WorkDayEntry(),
                        defaultHours: diContainer.settingsManager.notificationSettings.defaultHoursPerDay,
                        onWorkTypeSelected: { workType in
                            selectWorkTypeForDate(date: date, workType: workType)
                        },
                        onAdvancedTapped: {
                            showingAdvancedEntry = date
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button("Clear All") {
                    clearAllEntries()
                }
                .buttonStyle(ClearButtonStyle())
                .frame(maxWidth: .infinity)

                Button("Save") {
                    saveWorkDays()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Helper Properties

    private var weekDates: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        var dates: [Date] = []

        for i in 0..<7 {
            if let weekDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(weekDate)
            }
        }

        return dates
    }

    private var weekStartDateString: String {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return DateFormatters.shortDate.string(from: startOfWeek)
    }

    // MARK: - Actions

    private func loadExistingData() {
        isLoading = true

        Task {
            await MainActor.run {
                for weekDate in weekDates {
                    if let workDay = existingWorkDays.first(where: { calendar.isDate($0.date, inSameDayAs: weekDate) }) {
                        let entry = WorkDayEntry(from: workDay)
                        weeklyEntries[weekDate] = entry
                    }
                }
                isLoading = false
            }
        }
    }

    private func selectWorkTypeForDate(date: Date, workType: WorkType) {
        let currentEntry = weeklyEntries[date] ?? WorkDayEntry()
        var newEntry = currentEntry

        if currentEntry.selectedWorkType == workType {
            // Deselect if already selected
            newEntry.clear()
        } else {
            // Select new work type with default hours
            let defaultHours = diContainer.settingsManager.notificationSettings.defaultHoursPerDay
            newEntry.setWorkType(workType, hours: defaultHours)
        }

        weeklyEntries[date] = newEntry
    }

    private func clearAllEntries() {
        weeklyEntries.removeAll()
    }

    private func saveWorkDays() {
        isLoading = true

        Task {
            var workDaysToSave: [WorkDay] = []

            for weekDate in weekDates {
                let entry = weeklyEntries[weekDate] ?? WorkDayEntry()
                let workDay = entry.toWorkDay(for: weekDate)
                workDaysToSave.append(workDay)
            }

            onSave(workDaysToSave)
        }
    }

    private func advancedEntrySheet(for date: Date) -> some View {
        DayAdvancedEntryView(
            date: date,
            existingEntry: weeklyEntries[date],
            onSave: { entry in
                weeklyEntries[date] = entry
                showingAdvancedEntry = nil
            },
            onCancel: {
                showingAdvancedEntry = nil
            }
        )
    }
}

#Preview {
    let sampleDate = Date()
    let sampleWorkDay = WorkDay(date: sampleDate, workEntries: [.home: 8.0])

    WorkHoursEntryView(
        date: sampleDate,
        existingWorkDay: sampleWorkDay,
        existingWorkDays: [sampleWorkDay],
        onSave: { _ in },
        onCancel: { }
    )
    .environmentObject(DIContainer.shared)
}