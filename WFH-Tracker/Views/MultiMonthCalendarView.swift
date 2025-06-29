import SwiftUI

struct MultiMonthCalendarView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    let onDayTap: (Date) -> Void
    
    @State private var currentPageIndex: Int = 1 // Start at current month (middle)
    
    var body: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { dayName in
                    Text(dayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 30)
                }
            }
            .padding(.horizontal, 20)
            
            // Multi-month calendar with horizontal paging
            TabView(selection: $currentPageIndex) {
                ForEach(Array(calendarManager.visibleMonths.enumerated()), id: \.offset) { index, month in
                    CalendarView(
                        calendarMonth: month,
                        workDays: calendarManager.workDays,
                        onDayTap: onDayTap
                    )
                    .tag(index)
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
        } else if newIndex == 2 {
            // Scrolled to next month
            calendarManager.nextMonth()
            currentPageIndex = 1 // Reset to middle
        }
    }
}

#Preview {
    let calendarManager = CalendarStateManager()
    
    MultiMonthCalendarView(
        calendarManager: calendarManager,
        onDayTap: { _ in }
    )
} 