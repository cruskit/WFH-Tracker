import SwiftUI
import OSLog

struct MultiMonthCalendarView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    let displayWeekends: Bool
    let onDayTap: (Date) -> Void

    @State private var currentPageIndex: Int = 1 // Start at current month (middle)
    
    private let calendar = Calendar.current
    
    private var dayHeaders: [String] {
        if displayWeekends {
            // Show all 7 days
            let weekdaySymbols = calendar.weekdaySymbols
            let firstWeekday = calendar.firstWeekday

            var headers: [String] = []
            for i in 0..<7 {
                let index = (firstWeekday - 1 + i) % 7
                headers.append(String(weekdaySymbols[index].prefix(3)))
            }
            return headers
        } else {
            // Show only Monday through Friday
            return ["Mon", "Tue", "Wed", "Thu", "Fri"]
        }
    }

    private var dayWidth: CGFloat {
        displayWeekends ? 50 : 70
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(dayHeaders, id: \.self) { dayName in
                    Text(dayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: dayWidth, height: 30)
                }
            }
            .padding(.horizontal, 20)
            
            // Multi-month calendar with horizontal paging
            TabView(selection: $currentPageIndex) {
                ForEach(Array(calendarManager.visibleMonths.enumerated()), id: \.offset) { index, month in
                    LazyCalendarView(
                        calendarMonth: month,
                        workDays: calendarManager.workDays,
                        displayWeekends: displayWeekends,
                        onDayTap: onDayTap
                    )
                    .tag(index)
                    .id("month-\(index)-weekends-\(displayWeekends)") // Force refresh when displayWeekends changes
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 400)
            .onChange(of: currentPageIndex) { oldValue, newValue in
                handlePageChange(newValue)
            }
        }
    }
    
    private func handlePageChange(_ newIndex: Int) {
        // Handle page changes to update current month
        if newIndex == 0 {
            // Scrolled to previous month
            calendarManager.previousMonth()
            currentPageIndex = 1 // Reset to middle
            Logger.ui.logInfo("Navigated to previous month", context: "MultiMonthCalendarView")
        } else if newIndex == 2 {
            // Scrolled to next month
            calendarManager.nextMonth()
            currentPageIndex = 1 // Reset to middle
            Logger.ui.logInfo("Navigated to next month", context: "MultiMonthCalendarView")
        }
    }
}

#Preview {
    let calendarManager = CalendarStateManager()

    MultiMonthCalendarView(
        calendarManager: calendarManager,
        displayWeekends: true,
        onDayTap: { _ in }
    )
} 