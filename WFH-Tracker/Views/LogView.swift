//
//  LogView.swift
//  WFH-Tracker
//
//  Created by Paul Ruskin on 29/6/2025.
//

import SwiftUI
import OSLog

struct IdentifiableDate: Identifiable, Equatable {
    let id: Date
    var date: Date { id }
    init(_ date: Date) { self.id = date }
}

struct LogView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var appState: AppState
    @State private var selectedDate: IdentifiableDate?
    @State private var isLoading = false

    // Computed property to ensure we observe settings changes
    private var displayWeekends: Bool {
        diContainer.settingsManager.notificationSettings.displayWeekends
    }

    // MARK: - Financial Year Calculations

    private func getFinancialYear(for month: CalendarMonth) -> Int {
        // Financial year runs from July 1 to June 30
        // If month is July or later, financial year is current year + 1
        // If month is January to June, financial year is current year
        return month.month >= 7 ? month.year + 1 : month.year
    }

    private func getFinancialYearDate(for month: CalendarMonth) -> CalendarMonth {
        let financialYear = getFinancialYear(for: month)
        // Create a date in July of the financial year start
        let calendar = Calendar.current
        let components = DateComponents(year: financialYear - 1, month: 7, day: 1)
        let date = calendar.date(from: components) ?? Date()
        return CalendarMonth(date: date)
    }

    private func getWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        var dates: [Date] = []

        for i in 0..<7 {
            if let weekDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(weekDate)
            }
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            CalendarNavigationView(calendarManager: diContainer.calendarStateManager)
                .accessibilityAddTraits(.isHeader)

            Divider()

            // Calendar View
            if isLoading {
                loadingView
            } else {
                calendarView
            }

            // Totals Section
            totalsSection
        }
        .background(Color(.systemBackground))
        .onChange(of: appState.shouldShowCurrentWeekEntry) { _, shouldShow in
            if shouldShow {
                handleNotificationTap()
            }
        }
        .sheet(item: $selectedDate) { identifiableDate in
            workHoursEntrySheet(for: identifiableDate)
        }
        .onAppear {
            Logger.ui.logInfo("LogView appeared", context: "LogView")
        }
    }

    // MARK: - View Components

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading calendar...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Loading calendar data")
    }

    private var calendarView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                MultiMonthCalendarView(
                    calendarManager: diContainer.calendarStateManager,
                    displayWeekends: displayWeekends,
                    onDayTap: handleDayTap
                )
                .id("calendar-\(displayWeekends)") // Force refresh when displayWeekends changes
                .animation(.easeInOut(duration: 0.3), value: displayWeekends)
            }
            .padding(.top, 16)
        }
        .accessibilityLabel("Calendar view")
    }

    private var totalsSection: some View {
        HStack(spacing: 16) {
            TotalsCard(
                title: diContainer.calendarStateManager.currentMonth.monthName,
                totals: diContainer.calendarStateManager.getMonthlyTotals(
                    for: diContainer.calendarStateManager.currentMonth
                )
            )
            .accessibilityAddTraits(.isSummaryElement)

            TotalsCard(
                title: "FY \(getFinancialYear(for: diContainer.calendarStateManager.currentMonth))",
                totals: diContainer.calendarStateManager.getYearlyTotals(
                    for: getFinancialYearDate(for: diContainer.calendarStateManager.currentMonth)
                )
            )
            .accessibilityAddTraits(.isSummaryElement)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Work hours summary")
    }

    // MARK: - Actions

    private func handleDayTap(_ date: Date) {
        selectedDate = IdentifiableDate(date)
        Logger.ui.logInfo("Day tapped: \(date)", context: "LogView")
    }

    private func handleNotificationTap() {
        selectedDate = IdentifiableDate(Date())
        appState.resetNotificationState()
        Logger.ui.logInfo("Notification tap handled", context: "LogView")
    }

    private func workHoursEntrySheet(for identifiableDate: IdentifiableDate) -> some View {
        let weekDates = getWeekDates(for: identifiableDate.date)
        let existingWorkDays = diContainer.calendarStateManager.getWorkDays(for: weekDates)

        return WorkHoursEntryView(
            date: identifiableDate.date,
            existingWorkDay: diContainer.calendarStateManager.getWorkDay(for: identifiableDate.date),
            existingWorkDays: existingWorkDays,
            onSave: handleWorkDaysSave,
            onCancel: handleWorkHoursCancel
        )
    }

    private func handleWorkDaysSave(_ workDays: [WorkDay]) {
        isLoading = true
        Task {
            await diContainer.calendarStateManager.updateWorkDays(workDays)
            await MainActor.run {
                selectedDate = nil
                isLoading = false
            }
            Logger.ui.logInfo("Work days saved: \(workDays.count)", context: "LogView")
        }
    }

    private func handleWorkHoursCancel() {
        selectedDate = nil
        Logger.ui.logInfo("Work hours entry cancelled", context: "LogView")
    }
}

#Preview {
    LogView()
        .environmentObject(DIContainer.shared)
        .environmentObject(AppState())
}