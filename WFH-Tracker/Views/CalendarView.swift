import SwiftUI

struct CalendarView: View {
    let calendarMonth: CalendarMonth
    let workDays: [WorkDay]
    let displayWeekends: Bool
    let onDayTap: (Date) -> Void

    private var weeks: [[Date]] {
        displayWeekends ? calendarMonth.filteredWeeks : calendarMonth.weekdaysOnly(from: calendarMonth.filteredWeeks)
    }

    var body: some View {
        LazyVStack(spacing: 7) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 7) {
                    ForEach(week, id: \.self) { date in
                        let workDay = workDays.first {
                            Calendar.current.isDate($0.date, inSameDayAs: date)
                        }
                        DayCell(
                            date: date,
                            workDay: workDay,
                            isCurrentMonth: calendarMonth.isDateInCurrentMonth(date),
                            displayWeekends: displayWeekends,
                            onTap: { onDayTap(date) }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }
}

#Preview {
    CalendarView(
        calendarMonth: CalendarMonth(),
        workDays: [WorkDay(date: Date(), workEntries: [.home: 8])],
        displayWeekends: true,
        onDayTap: { _ in }
    )
    .background(Color.breezeBackground)
}
