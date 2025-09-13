import SwiftUI

struct WorkHoursEntryView: View {
    let date: Date
    let existingWorkDay: WorkDay?
    let existingWorkDays: [WorkDay]
    let onSave: ([WorkDay]) -> Void
    let onCancel: () -> Void

    @State private var weeklyEntries: [Date: WorkDayEntry] = [:]
    @State private var showingAdvancedEntry: Date?
    @State private var showingValidationError = false
    @State private var validationMessage = ""

    @ObservedObject private var settingsManager = SettingsManager.shared

    private let calendar = Calendar.current

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    private let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 12) {
            // Header
            VStack(spacing: 4) {
                Text("Weekly Working Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Week of \(weekStartDateString)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 12)

            // Work Type Selection - Compact Layout
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(weekDates, id: \.self) { date in
                        CompactDayEntryRow(
                            date: date,
                            entry: weeklyEntries[date] ?? WorkDayEntry(),
                            defaultHours: settingsManager.notificationSettings.defaultHoursPerDay,
                            onWorkTypeSelected: { workType in
                                selectWorkTypeForDate(date: date, workType: workType)
                            },
                            onAdvancedTapped: {
                                showingAdvancedEntry = date
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 8) {
                Button("Save") {
                    saveWorkDays()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Clear All") {
                    weeklyEntries.removeAll()
                }
                .buttonStyle(ClearButtonStyle())

                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
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
            DayAdvancedEntryView(
                date: dateWrapper.date,
                existingEntry: weeklyEntries[dateWrapper.date],
                onSave: { entry in
                    weeklyEntries[dateWrapper.date] = entry
                    showingAdvancedEntry = nil
                },
                onCancel: {
                    showingAdvancedEntry = nil
                }
            )
        }
        .onAppear {
            loadExistingData()
        }
        .background(Color(.systemBackground))
    }

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
        return shortDateFormatter.string(from: startOfWeek)
    }

    private func loadExistingData() {
        for weekDate in weekDates {
            if let workDay = existingWorkDays.first(where: { calendar.isDate($0.date, inSameDayAs: weekDate) }) {
                let entry = WorkDayEntry(from: workDay)
                weeklyEntries[weekDate] = entry
            }
        }
    }

    private func selectWorkTypeForDate(date: Date, workType: WorkType) {
        let currentEntry = weeklyEntries[date] ?? WorkDayEntry()

        if currentEntry.selectedWorkType == workType {
            // Deselect if already selected
            weeklyEntries[date] = WorkDayEntry()
        } else {
            // Select new work type with default hours
            var newEntry = WorkDayEntry()
            newEntry.selectedWorkType = workType
            newEntry.workEntries = [workType: settingsManager.notificationSettings.defaultHoursPerDay]
            weeklyEntries[date] = newEntry
        }
    }

    private func saveWorkDays() {
        var workDaysToSave: [WorkDay] = []

        for weekDate in weekDates {
            let entry = weeklyEntries[weekDate] ?? WorkDayEntry()
            let workDay = WorkDay(date: weekDate, workEntries: entry.workEntries)
            workDaysToSave.append(workDay)
        }

        onSave(workDaysToSave)
    }
}

// MARK: - Supporting Types

struct WorkDayEntry {
    var selectedWorkType: WorkType?
    var workEntries: [WorkType: Double] = [:]
    var isAdvanced: Bool = false

    init() {}

    init(from workDay: WorkDay) {
        self.workEntries = workDay.workEntries
        self.isAdvanced = workDay.isAdvancedEntry

        if !isAdvanced && workDay.activeWorkTypes.count == 1 {
            self.selectedWorkType = workDay.activeWorkTypes.first
        }
    }

    var hasData: Bool {
        !workEntries.isEmpty
    }
}

struct DateWrapper: Identifiable {
    let id = UUID()
    let date: Date
}

// MARK: - Day Entry Row Component

struct DayEntryRow: View {
    let date: Date
    let entry: WorkDayEntry
    let defaultHours: Double
    let onWorkTypeSelected: (WorkType) -> Void
    let onAdvancedTapped: () -> Void

    private let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 12) {
            // Date Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayNameFormatter.string(from: date))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if entry.isAdvanced {
                    Text("Advanced")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            // Work Type Buttons
            HStack(spacing: 12) {
                ForEach(WorkType.allCases, id: \.self) { workType in
                    WorkTypeButton(
                        workType: workType,
                        isSelected: entry.selectedWorkType == workType,
                        isActive: entry.workEntries[workType] != nil,
                        onTapped: {
                            onWorkTypeSelected(workType)
                        }
                    )
                }
            }

            // Advanced Entry Button
            Button("Advanced Entry") {
                onAdvancedTapped()
            }
            .buttonStyle(AdvancedButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .opacity(entry.hasData ? 0.8 : 0.3)
        )
    }
}

// MARK: - Work Type Button Component

struct WorkTypeButton: View {
    let workType: WorkType
    let isSelected: Bool
    let isActive: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            VStack(spacing: 4) {
                Text(workType.icon)
                    .font(.system(size: 24))

                Text(workType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .foregroundColor(textColor)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        if isSelected {
            return workType.backgroundColor
        } else if isActive {
            return workType.backgroundColor.opacity(0.5)
        } else {
            return Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        if isSelected {
            return workType.color
        } else if isActive {
            return workType.color.opacity(0.5)
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 2 : (isActive ? 1 : 0)
    }

    private var textColor: Color {
        if isSelected || isActive {
            return workType.color
        } else {
            return .secondary
        }
    }
}

// MARK: - Compact Work Type Button Component

struct CompactWorkTypeButton: View {
    let workType: WorkType
    let isSelected: Bool
    let isActive: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            Text(workType.icon)
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                )
                .foregroundColor(textColor)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        if isSelected {
            return workType.backgroundColor
        } else if isActive {
            return workType.backgroundColor.opacity(0.5)
        } else {
            return Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        if isSelected {
            return workType.color
        } else if isActive {
            return workType.color.opacity(0.5)
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 2 : (isActive ? 1 : 0)
    }

    private var textColor: Color {
        if isSelected || isActive {
            return workType.color
        } else {
            return .secondary
        }
    }
}

// MARK: - Compact Day Entry Row Component

struct CompactDayEntryRow: View {
    let date: Date
    let entry: WorkDayEntry
    let defaultHours: Double
    let onWorkTypeSelected: (WorkType) -> Void
    let onAdvancedTapped: () -> Void

    private let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 8) {
            // Day Info - Fixed width
            VStack(spacing: 1) {
                Text(dayNameFormatter.string(from: date))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text(dayNumberFormatter.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(width: 40, alignment: .center)

            // Work Type Buttons
            HStack(spacing: 6) {
                ForEach(WorkType.allCases, id: \.self) { workType in
                    CompactWorkTypeButton(
                        workType: workType,
                        isSelected: entry.selectedWorkType == workType,
                        isActive: entry.workEntries[workType] != nil,
                        onTapped: {
                            onWorkTypeSelected(workType)
                        }
                    )
                }
            }

            Spacer()

            // Advanced Entry Button - Icon only
            Button(action: onAdvancedTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .opacity(entry.hasData ? 0.6 : 0.2)
        )
    }
}

// MARK: - Custom Button Styles

struct AdvancedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
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
}