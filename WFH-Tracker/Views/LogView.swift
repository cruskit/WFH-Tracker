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

    private let calendar = Calendar.current

    private var calendarManager: CalendarStateManager { diContainer.calendarStateManager }

    private var displayWeekends: Bool {
        diContainer.settingsManager.notificationSettings.displayWeekends
    }

    // MARK: - Financial year helpers

    private func financialYear(for month: CalendarMonth) -> Int {
        month.month >= 7 ? month.year + 1 : month.year
    }

    private func financialYearStartMonth(for month: CalendarMonth) -> CalendarMonth {
        let fy = financialYear(for: month)
        let comps = DateComponents(year: fy - 1, month: 7, day: 1)
        return CalendarMonth(date: calendar.date(from: comps) ?? Date())
    }

    private func fyLabel(for month: CalendarMonth) -> String {
        let fy = financialYear(for: month)
        return "FY \(fy - 1)–\(String(fy).suffix(2)) days"
    }

    // MARK: - Week helpers

    private func weekDates(for date: Date) -> [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var mondayWeekDates: [Date] {
        // Always show Mon–Sun for the current week
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        comps.weekday = 2 // Monday
        guard let monday = calendar.date(from: comps) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private var weekdayDates: [Date] {
        mondayWeekDates.filter {
            let dow = calendar.component(.weekday, from: $0)
            return dow != 1 && dow != 7
        }
    }

    private var loggedWeekdayCount: Int {
        weekdayDates.filter { calendarManager.getWorkDay(for: $0)?.hasData == true }.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            greetingHeader

            ScrollView {
                VStack(spacing: 0) {
                    calendarSection
                        .padding(.top, 20)

                    totalsSection
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
            }
        }
        .background(Color.breezeBackground.ignoresSafeArea())
        .onChange(of: appState.shouldShowCurrentWeekEntry) { _, shouldShow in
            if shouldShow { handleNotificationTap() }
        }
        .sheet(item: $selectedDate) { identifiableDate in
            workHoursEntrySheet(for: identifiableDate)
        }
        .onAppear {
            Logger.ui.logInfo("LogView appeared", context: "LogView")
        }
    }

    // MARK: - Greeting header

    private var greetingHeader: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Hi there 👋")
                    .font(.breezeDisplay(24))
                    .foregroundStyle(Color.breezeInk)
                Text("Let's keep your log up to date")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.breezeInkFaint)
            }

            Spacer()

            // Compact month navigator
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { calendarManager.previousMonth() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.breezeInkMuted)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color.breezeSurface)
                                .overlay(Circle().strokeBorder(Color.breezeLine, lineWidth: 1))
                        )
                }
                .accessibilityLabel("Previous month")

                Text(shortMonthYear)
                    .font(.breezeDisplay(17))
                    .foregroundStyle(Color.breezeInk)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { calendarManager.nextMonth() }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.breezeInkMuted)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color.breezeSurface)
                                .overlay(Circle().strokeBorder(Color.breezeLine, lineWidth: 1))
                        )
                }
                .accessibilityLabel("Next month")
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .background(Color.breezeBackground)
    }

    private var shortMonthYear: String {
        let m = calendarManager.currentMonth
        let abbrev = String(m.monthName.prefix(3))
        return "\(abbrev) \(m.year)"
    }

    // MARK: - Week hero card

    private var weekHeroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Pill + progress
            HStack {
                Text("This week")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.breezeBrandInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.breezeBrandSoft))

                Spacer()

                Text("\(loggedWeekdayCount)/5 weekdays")
                    .font(.system(size: 12.5, weight: .heavy))
                    .foregroundStyle(Color.breezeInkFaint)
            }

            Text(loggedWeekdayCount >= 5 ? "Your week is all set 🎉" : "Nearly there!")
                .font(.breezeDisplay(18))
                .foregroundStyle(Color.breezeInk)
                .padding(.top, 4)

            Text(weekSubtitle)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(Color.breezeInkMuted)
                .padding(.top, 2)

            weekStrip
                .padding(.top, 15)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.breezeSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.breezeLine, lineWidth: 1)
                )
        )
        .breezeShadowMd()
    }

    private var weekSubtitle: String {
        if loggedWeekdayCount >= 5 { return "Nice — every weekday is logged." }
        let left = 5 - loggedWeekdayCount
        return "Tap below to log the \(left) day\(left == 1 ? "" : "s") you're missing."
    }

    private let weekLetters = ["M", "T", "W", "T", "F", "S", "S"]

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array((displayWeekends ? mondayWeekDates : weekdayDates).enumerated()), id: \.offset) { index, date in
                let types = calendarManager.getWorkDay(for: date)?.activeWorkTypes ?? []
                let isToday = calendar.isDateInToday(date)
                let dayNum = calendar.component(.day, from: date)
                let letter = index < weekLetters.count ? weekLetters[index] : ""

                VStack(spacing: 7) {
                    Text(letter)
                        .font(.system(size: 10.5, weight: .heavy))
                        .foregroundStyle(Color.breezeInkFaint)

                    ZStack(alignment: .topLeading) {
                        // Background fill
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(weekCellBg(types: types))

                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(
                                isToday ? Color.breezeBrand : (types.count == 1 ? types[0].color : Color.clear),
                                lineWidth: isToday ? 2.5 : 1.5
                            )

                        // Day number
                        Text("\(dayNum)")
                            .font(.breezeDisplay(10))
                            .foregroundStyle(types.count == 1 ? types[0].inkColor : Color.breezeInkFaint)
                            .padding(.horizontal, 5)
                            .padding(.top, 4)

                        // Emoji
                        weekCellEmoji(types: types)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 8)
                    }
                    .aspectRatio(CGSize(width: 1, height: 1.06), contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selectedDate = IdentifiableDate(date) }
            }
        }
    }

    private func weekCellBg(types: [WorkType]) -> Color {
        switch types.count {
        case 0: return Color.breezeSurfaceSunken
        case 1: return types[0].softColor
        default: return Color.breezeSurface
        }
    }

    @ViewBuilder
    private func weekCellEmoji(types: [WorkType]) -> some View {
        if types.count == 1 {
            Text(types[0].icon).font(.system(size: 14))
        } else if types.count > 1 {
            HStack(spacing: 0) {
                ForEach(types, id: \.self) { Text($0.icon).font(.system(size: 10)) }
            }
        }
    }

    // MARK: - Calendar section

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(calendarManager.currentMonth.monthName)
                    .font(.breezeDisplay(16))
                    .foregroundStyle(Color.breezeInk)
                Spacer()
                Text("tap a day to edit ›")
                    .font(.system(size: 11.5, weight: .heavy))
                    .foregroundStyle(Color.breezeInkFaint)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 9)

            MultiMonthCalendarView(
                calendarManager: calendarManager,
                displayWeekends: displayWeekends,
                onDayTap: handleDayTap
            )
            .id("calendar-\(displayWeekends)")
            .animation(.easeInOut(duration: 0.3), value: displayWeekends)
        }
    }

    // MARK: - Totals section

    private var totalsSection: some View {
        HStack(spacing: 11) {
            TotalsCard(
                title: calendarManager.currentMonth.monthName + " days",
                totals: calendarManager.getMonthlyTotals(for: calendarManager.currentMonth),
                hoursPerDay: diContainer.settingsManager.notificationSettings.defaultHoursPerDay
            )
            TotalsCard(
                title: fyLabel(for: calendarManager.currentMonth),
                totals: calendarManager.getYearlyTotals(
                    for: financialYearStartMonth(for: calendarManager.currentMonth)
                ),
                isWarm: true,
                hoursPerDay: diContainer.settingsManager.notificationSettings.defaultHoursPerDay
            )
        }
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

    private func workHoursEntrySheet(for identifiable: IdentifiableDate) -> some View {
        let wd = weekDates(for: identifiable.date)
        let existing = calendarManager.getWorkDays(for: wd)
        return WorkHoursEntryView(
            date: identifiable.date,
            existingWorkDay: calendarManager.getWorkDay(for: identifiable.date),
            existingWorkDays: existing,
            onSave: handleWorkDaysSave,
            onCancel: { selectedDate = nil }
        )
    }

    private func handleWorkDaysSave(_ workDays: [WorkDay]) {
        Task {
            await calendarManager.updateWorkDays(workDays)
            await MainActor.run { selectedDate = nil }
            Logger.ui.logInfo("Work days saved: \(workDays.count)", context: "LogView")
        }
    }
}

#Preview {
    LogView()
        .environmentObject(DIContainer.shared)
        .environmentObject(AppState())
}
