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
    @State private var isLoading = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.breezeLineStrong)
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // Title
            Text("Log your week")
                .font(.breezeDisplay(23))
                .foregroundStyle(Color.breezeInk)

            Text("Tap a type to log a full day · ⚙ for split days")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.breezeInkMuted)
                .padding(.top, 5)
                .padding(.bottom, 14)

            Divider()
                .overlay(Color.breezeLine)

            // Day rows
            if isLoading {
                Spacer()
                ProgressView()
                    .tint(Color.breezeBrand)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 9) {
                        ForEach(weekDates, id: \.self) { date in
                            CompactDayEntryRow(
                                date: date,
                                entry: weeklyEntries[date] ?? WorkDayEntry(),
                                defaultHours: diContainer.settingsManager.notificationSettings.defaultHoursPerDay,
                                onWorkTypeSelected: { selectWorkType($0, for: date) },
                                onAdvancedTapped: { showingAdvancedEntry = date }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }

            // Action buttons
            HStack(spacing: 10) {
                Button("Clear all") { weeklyEntries.removeAll() }
                    .buttonStyle(ClearButtonStyle())
                    .frame(maxWidth: .infinity)

                Button("Save week") { saveWorkDays() }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.bottom, 22)
            .padding(.top, 8)
        }
        .background(Color.breezeSurfaceSunken.ignoresSafeArea())
        .sheet(item: Binding<DateWrapper?>(
            get: { showingAdvancedEntry.map(DateWrapper.init) },
            set: { _ in showingAdvancedEntry = nil }
        )) { wrapper in
            DayAdvancedEntryView(
                date: wrapper.date,
                existingEntry: weeklyEntries[wrapper.date],
                onSave: { entry in
                    weeklyEntries[wrapper.date] = entry
                    showingAdvancedEntry = nil
                },
                onCancel: { showingAdvancedEntry = nil }
            )
        }
        .onAppear { loadExistingData() }
    }

    // MARK: - Helpers

    private var weekDates: [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func loadExistingData() {
        isLoading = true
        Task {
            await MainActor.run {
                for d in weekDates {
                    if let wd = existingWorkDays.first(where: { calendar.isDate($0.date, inSameDayAs: d) }) {
                        weeklyEntries[d] = WorkDayEntry(from: wd)
                    }
                }
                isLoading = false
            }
        }
    }

    private func selectWorkType(_ workType: WorkType, for date: Date) {
        var entry = weeklyEntries[date] ?? WorkDayEntry()
        if entry.selectedWorkType == workType {
            entry.clear()
        } else {
            entry.clear()
            entry.setWorkType(workType, hours: diContainer.settingsManager.notificationSettings.defaultHoursPerDay)
        }
        weeklyEntries[date] = entry
    }

    private func saveWorkDays() {
        let workDays = weekDates.map { (weeklyEntries[$0] ?? WorkDayEntry()).toWorkDay(for: $0) }
        onSave(workDays)
    }
}

#Preview {
    WorkHoursEntryView(
        date: Date(),
        existingWorkDay: nil,
        existingWorkDays: [],
        onSave: { _ in },
        onCancel: {}
    )
    .environmentObject(DIContainer.shared)
}
