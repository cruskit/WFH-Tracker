import Foundation

struct CalendarMonth: Equatable {
    let date: Date
    let calendar = Calendar.current
    
    init(date: Date = Date()) {
        self.date = date
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var month: Int {
        calendar.component(.month, from: date)
    }
    
    var year: Int {
        calendar.component(.year, from: date)
    }
    
    var weeks: [[Date]] {
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let startOfFirstWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []
        var currentDate = startOfFirstWeek
        
        // Generate 6 weeks to ensure we cover the entire month
        for _ in 0..<42 {
            currentWeek.append(currentDate)
            
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return weeks
    }

    func weekdaysOnly(from weeks: [[Date]]) -> [[Date]] {
        return weeks.map { week in
            week.filter { date in
                let weekday = calendar.component(.weekday, from: date)
                return weekday != 1 && weekday != 7 // Exclude Sunday (1) and Saturday (7)
            }
        }
    }

    func nextMonth() -> CalendarMonth {
        let nextDate = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        return CalendarMonth(date: nextDate)
    }
    
    func previousMonth() -> CalendarMonth {
        let previousDate = calendar.date(byAdding: .month, value: -1, to: date) ?? date
        return CalendarMonth(date: previousDate)
    }
    
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }
} 