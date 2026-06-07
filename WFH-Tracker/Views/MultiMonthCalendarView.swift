import SwiftUI
import OSLog

struct MultiMonthCalendarView: View {
    @ObservedObject var calendarManager: CalendarStateManager
    let displayWeekends: Bool
    let onDayTap: (Date) -> Void

    @State private var currentPageIndex: Int = 1

    private let calendar = Calendar.current

    private var dayHeaders: [String] {
        if displayWeekends {
            let symbols = calendar.weekdaySymbols
            let first = calendar.firstWeekday
            return (0..<7).map { i in String(symbols[(first - 1 + i) % 7].prefix(1)) }
        } else {
            return ["M", "T", "W", "T", "F"]
        }
    }

    private var calendarHeight: CGFloat {
        let cols = CGFloat(displayWeekends ? 7 : 5)
        let sidePad: CGFloat = 36
        let gaps = (cols - 1) * 7
        let cellW = (UIScreen.main.bounds.width - sidePad - gaps) / cols
        let cellH = cellW * 1.04
        return 6 * (cellH + 7)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Single-letter day headers
            HStack(spacing: 0) {
                ForEach(Array(dayHeaders.enumerated()), id: \.offset) { _, name in
                    Text(name)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.breezeInkFaint)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 6)

            // Swipeable month pages
            TabView(selection: $currentPageIndex) {
                ForEach(Array(calendarManager.visibleMonths.enumerated()), id: \.offset) { index, month in
                    LazyCalendarView(
                        calendarMonth: month,
                        workDays: calendarManager.workDays,
                        displayWeekends: displayWeekends,
                        onDayTap: onDayTap
                    )
                    .tag(index)
                    .id("month-\(index)-weekends-\(displayWeekends)")
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: calendarHeight)
            .onChange(of: currentPageIndex) { _, newValue in
                handlePageChange(newValue)
            }
        }
    }

    private func handlePageChange(_ newIndex: Int) {
        if newIndex == 0 {
            calendarManager.previousMonth()
            currentPageIndex = 1
            Logger.ui.logInfo("Navigated to previous month", context: "MultiMonthCalendarView")
        } else if newIndex == 2 {
            calendarManager.nextMonth()
            currentPageIndex = 1
            Logger.ui.logInfo("Navigated to next month", context: "MultiMonthCalendarView")
        }
    }
}

#Preview {
    MultiMonthCalendarView(
        calendarManager: CalendarStateManager(),
        displayWeekends: true,
        onDayTap: { _ in }
    )
    .background(Color.breezeBackground)
}
