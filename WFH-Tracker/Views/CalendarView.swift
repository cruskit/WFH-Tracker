import SwiftUI

struct CalendarView: View {
    let calendarMonth: CalendarMonth
    let workDays: [WorkDay]
    let displayWeekends: Bool
    let onDayTap: (Date) -> Void

    private var weeks: [[Date]] {
        if displayWeekends {
            return calendarMonth.weeks
        } else {
            return calendarMonth.weekdaysOnly(from: calendarMonth.weeks)
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { date in
                        let workDay = workDays.first { workDay in
                            Calendar.current.isDate(workDay.date, inSameDayAs: date)
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
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    let sampleWorkDays = [
        WorkDay(date: Date(), homeHours: 4.5, officeHours: 3.0),
        WorkDay(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), homeHours: 8.0, officeHours: nil)
    ]
    
    CalendarView(
        calendarMonth: CalendarMonth(),
        workDays: sampleWorkDays,
        displayWeekends: true,
        onDayTap: { _ in }
    )
} 